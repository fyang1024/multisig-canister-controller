import IC "./ic";
import Proposal "./Proposal";
import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Principal "mo:base/Principal";
import Buffer "mo:base/Buffer";
import TrieMap "mo:base/TrieMap";

shared(msg) actor class () = self {

    private var owners: [Principal] = [];
    private var minimal_sigs: Nat = 0;
    private var canisters = TrieMap.TrieMap<IC.canister_id, Buffer.Buffer<Proposal.Proposal>>(Principal.equal, Principal.hash);

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
        assert(is_one_of_owners(msg.caller));
        let settings = {
            freezing_threshold = null;
            controllers = ?[Principal.fromActor(self)];
            memory_allocation = null;
            compute_allocation = null;
        };
        let ic: IC.Self = actor("aaaaa-aa");
        let result = await ic.create_canister({ settings = ?settings });
        canisters.put(result.canister_id, Buffer.Buffer<Proposal.Proposal>(3));
        result.canister_id
    };

    public shared (msg) func install_code(code: Blob, canister_id: IC.canister_id): async () {
        assert(is_one_of_owners(msg.caller));
        let ic: IC.Self = actor("aaaaa-aa");
        await ic.install_code({ 
            arg = [];
            wasm_module = Blob.toArray(code);
            mode = #install;
            canister_id = canister_id;
        });
    };

    public shared (msg) func start_canister(canister_id: IC.canister_id): async () {
        assert(is_one_of_owners(msg.caller));
        let ic: IC.Self = actor("aaaaa-aa");
        await ic.start_canister({ canister_id = canister_id });
    };

    public shared (msg) func stop_canister(canister_id: IC.canister_id): async () {
        assert(is_one_of_owners(msg.caller));
        let ic: IC.Self = actor("aaaaa-aa");
        await ic.stop_canister({ canister_id = canister_id });
    };

    public shared (msg) func delete_canister(canister_id: IC.canister_id): async () {
        assert(is_one_of_owners(msg.caller));
        let ic: IC.Self = actor("aaaaa-aa");
        await ic.delete_canister({ canister_id = canister_id });
    };

    public shared (msg) func propose(
        proposal_type: Proposal.ProposalType, 
        canister_id: IC.canister_id, 
        content: ?Blob
    ) {
        assert(canister_exists(canister_id));
        // make sure it's either the first proposal or last proposal has been executed
        assert(first_proposal_or_last_proposal_executed(canister_id));
        let proposal = Proposal.create_proposal(
            get_next_proposal_seq(canister_id),
            msg.caller,
            proposal_type,
            canister_id,
            content,
            minimal_sigs
        );
        switch (canisters.get(canister_id)) {
            case null {};
            case (?proposals) {
                proposals.add(proposal);
            }
        }
    };

    public shared (msg) func vote_for_last_proposal(canister_id: IC.canister_id) {
        assert(is_one_of_owners(msg.caller));
        assert(canister_exists(canister_id));
        assert(last_proposal_pending(canister_id));
        let new_proposal = Proposal.approve_propsal(msg.caller, last_proposal(canister_id));
        // TODO execute the proposal if the new_proposal's status is approved,
        // TODO and then update the status to be executed
        update_last_proposal(canister_id, new_proposal);
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

    private func first_proposal_or_last_proposal_executed(canister_id: IC.canister_id): Bool {
        let ?proposals = canisters.get(canister_id);
        proposals.size() == 0 or proposals.get(proposals.size() - 1).status == #executed
    };

    private func get_next_proposal_seq(canister_id: IC.canister_id): Nat {
        let ?proposals = canisters.get(canister_id);
        proposals.size()
    };

    private func last_proposal_pending(canister_id: IC.canister_id): Bool {
        let ?proposals = canisters.get(canister_id);
        proposals.size() > 0 and proposals.get(proposals.size() - 1).status == #pending
    };

    private func last_proposal(canister_id: IC.canister_id): Proposal.Proposal {
        let ?proposals = canisters.get(canister_id);
        proposals.get(proposals.size() - 1)
    };

    private func update_last_proposal(canister_id: IC.canister_id, proposal: Proposal.Proposal) {
        let ?proposals = canisters.get(canister_id);
        ignore proposals.removeLast();
        proposals.add(proposal);
    }
}
