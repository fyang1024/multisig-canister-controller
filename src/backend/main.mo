import IC "./ic";
import Proposal "./Proposal";
import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Principal "mo:base/Principal";
import Buffer "mo:base/Buffer";
import TrieMap "mo:base/TrieMap";
import Cycles "mo:base/ExperimentalCycles";

shared(msg) actor class MultisigCanisterController() = self {

    private var owners: [Principal] = [];
    private var minimal_sigs: Nat = 0;
    private var canisters = TrieMap.TrieMap<IC.canister_id, Buffer.Buffer<Proposal.Proposal>>(Principal.equal, Principal.hash);

    private let CYCLE_LIMIT = 1_000_000_000_000;
    private let ic: IC.Self = actor("aaaaa-aa");

    public func init(o: [Principal], m: Nat) {
        assert(m > 0 and m <= o.size());
        owners := o;
        minimal_sigs := m;
    };

    public query func get_owners(): async [Principal] {
        owners
    };

    public query func get_minimal_sigs(): async Nat {
        minimal_sigs
    };

    public query func get_last_proposal(canister_id: IC.canister_id): async ?Proposal.Proposal {
        switch (canisters.get(canister_id)) {
            case (null) { null };
            case (?proposals) { 
                if (proposals.size() == 0) { null } else { proposals.getOpt(proposals.size() - 1) }
            }
        }
    };

    public shared (msg) func create_canister() : async IC.canister_id {
        assert(is_one_of_owners(msg.caller)); // any of the owners can always create a canister
        Cycles.add(CYCLE_LIMIT); 
        let settings = {
            freezing_threshold = null;
            controllers = ?[Principal.fromActor(self)];
            memory_allocation = null;
            compute_allocation = null;
        };
        let result = await ic.create_canister({ settings = ?settings });
        canisters.put(result.canister_id, Buffer.Buffer<Proposal.Proposal>(3));
        result.canister_id
    };

    public shared (msg) func install_code(code: Blob, canister_id: IC.canister_id): async () {
        check_before_operation(canister_id, #installCode, msg.caller);
        await do_install_code(code, canister_id, #install);
    };

    public shared (msg) func upgrade_code(code: Blob, canister_id: IC.canister_id): async () {
        check_before_operation(canister_id, #upgradeCode, msg.caller);
        await do_install_code(code, canister_id, #upgrade);
    };

    public shared (msg) func reinstall_code(code: Blob, canister_id: IC.canister_id): async () {
        check_before_operation(canister_id, #reinstallCode, msg.caller);
        await do_install_code(code, canister_id, #reinstall);
    };

    public shared (msg) func uninstall_code(canister_id: IC.canister_id): async () {
        check_before_operation(canister_id, #uninstallCode, msg.caller);
        await ic.uninstall_code({ canister_id = canister_id });
    };

    public shared (msg) func start_canister(canister_id: IC.canister_id): async () {
        check_before_operation(canister_id, #startCanister, msg.caller);
        await ic.start_canister({ canister_id = canister_id });
    };

    public shared (msg) func stop_canister(canister_id: IC.canister_id): async () {
        check_before_operation(canister_id, #stopCanister, msg.caller);
        await ic.stop_canister({ canister_id = canister_id });
    };

    public shared (msg) func delete_canister(canister_id: IC.canister_id): async () {
        check_before_operation(canister_id, #deleteCanister, msg.caller);
        await ic.delete_canister({ canister_id = canister_id });
    };

    public shared (msg) func propose(
        proposal_type: Proposal.ProposalType,
        permission_change: ?Proposal.PermissionChange,
        canister_operation: Proposal.CanisterOperation, 
        canister_id: IC.canister_id, 
        code: ?Blob
    ) {
        check_before_propose(canister_id);
        let proposal = Proposal.create_proposal(
            canister_id,
            get_next_proposal_seq(canister_id),
            msg.caller,
            proposal_type,
            permission_change,
            canister_operation,
            code,
            minimal_sigs,
            owners.size()
        );
        switch (canisters.get(canister_id)) {
            case null {};
            case (?proposals) {
                proposals.add(proposal);
            }
        }
    };

    public shared (msg) func vote_for_last_proposal(canister_id: IC.canister_id): async () {
        check_before_vote(canister_id, msg.caller);
        switch (last_proposal(canister_id)) {
            case (?p) {
                let proposal = Proposal.approve_propsal(msg.caller, p);
                if (proposal.status == #approved and proposal.proposal_type == #operation) {
                    switch(proposal.canister_operation) {
                        case (#installCode) {
                            switch (proposal.code) {
                                case (?code) {
                                    await do_install_code(code, proposal.canister_id, #install);
                                };
                                case (null) {}
                            }
                        };
                        case (#upgradeCode) {
                            switch (proposal.code) {
                                case (?code) {
                                    await do_install_code(code, proposal.canister_id, #upgrade);
                                };
                                case (null) {}
                            }
                        };
                        case (#reinstallCode) {
                            switch (proposal.code) {
                                case (?code) {
                                    await do_install_code(code, proposal.canister_id, #reinstall);
                                };
                                case (null) {}
                            }
                        };
                        case (#uninstallCode) {
                            await ic.uninstall_code({ canister_id = proposal.canister_id });
                        };
                        case (#startCanister) {
                            await ic.start_canister({ canister_id = proposal.canister_id })
                        };
                        case (#stopCanister) {
                            await ic.stop_canister({ canister_id = proposal.canister_id })
                        };
                        case (#deleteCanister) {
                            await ic.delete_canister({ canister_id = proposal.canister_id })
                        };
                    };
                };
                update_last_proposal(canister_id, proposal);
            };
            case (null) {}
        }
    };

    public shared (msg) func vote_against_last_proposal(canister_id: IC.canister_id) {
        check_before_vote(canister_id, msg.caller);
        switch (last_proposal(canister_id)) {
            case (?p) {
                let proposal = Proposal.disapprove_proposal(msg.caller, p);
                update_last_proposal(canister_id, proposal);
            };
            case (null) {}
        }
    };

    private func do_install_code(
        code: Blob, 
        canister_id: IC.canister_id, 
        mode: { #install;#upgrade;#reinstall }
    ): async () {
        await ic.install_code({ 
            arg = [];
            wasm_module = Blob.toArray(code);
            mode = mode;
            canister_id = canister_id;
        });
    };

    private func check_before_operation(
        canister_id: IC.canister_id, 
        canister_operation: Proposal.CanisterOperation,
        caller: Principal
    ) {
        assert(canister_exists(canister_id));
        assert(no_proposal(canister_id) or not last_proposal_pending(canister_id));
        assert(not requires_multisig(canister_id, canister_operation));
        assert(is_one_of_owners(msg.caller));
    };

    private func check_before_vote(canister_id: IC.canister_id, caller: Principal) {
        assert(canister_exists(canister_id));
        assert(is_one_of_owners(msg.caller));
        assert(last_proposal_pending(canister_id));
    };

    private func check_before_propose(canister_id: IC.canister_id) {
        assert(canister_exists(canister_id));
        assert(is_one_of_owners(msg.caller));
        // make sure either there is no proposal yet, or last proposal is not pending
        assert(no_proposal(canister_id) or not last_proposal_pending(canister_id));
    };

    private func is_one_of_owners(p: Principal): Bool {
        switch(Array.find(owners, func (a: Principal): Bool { Principal.equal(a, p) })) {
            case (null) { false };
            case (_) { true };
        }
    };

    private func canister_exists(canister_id: IC.canister_id): Bool {
        switch(canisters.get(canister_id)) {
            case (null) { false };
            case (_) { true };
        }
    };

    private func no_proposal(canister_id: IC.canister_id): Bool {
        switch (canisters.get(canister_id)) {
            case (null) { true };
            case (?proposals) { proposals.size() == 0 }
        }
    };

    private func get_next_proposal_seq(canister_id: IC.canister_id): Nat {
        switch (canisters.get(canister_id)) {
            case (null) { 0 };
            case (?proposals) { proposals.size() }
        }
    };

    private func last_proposal_pending(canister_id: IC.canister_id): Bool {
        switch (canisters.get(canister_id)) {
            case (?proposals) { 
                proposals.size() > 0 and proposals.get(proposals.size() - 1).status == #pending
            };
            case (_) { false }
        }
    };

    private func last_proposal(canister_id: IC.canister_id): ?Proposal.Proposal {
        switch (canisters.get(canister_id)) {
            case (?proposals) { ?proposals.get(proposals.size() - 1) };
            case (null) { null }
        }
    };

    private func update_last_proposal(canister_id: IC.canister_id, proposal: Proposal.Proposal) {
        switch (canisters.get(canister_id)) {
            case (?proposals) { 
                ignore proposals.removeLast();
                proposals.add(proposal);
            };
            case (_) {}
        }
    };

    private func requires_multisig(canister_id: IC.canister_id, canister_operation: Proposal.CanisterOperation): Bool {
        switch (canisters.get(canister_id)) {
            case (?proposals) { 
                let last_proposal = proposals.get(proposals.size() - 1);
                last_proposal.status == #approved
                and
                last_proposal.canister_operation == canister_operation 
                and 
                last_proposal.permission_change == ?#requireMultiSig
            };
            case (null) { false }
        }
    };
}
