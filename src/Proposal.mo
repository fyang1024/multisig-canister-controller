import IC "./ic";
import Array "mo:base/Array";
import Principal "mo:base/Principal"

module {

    public type Proposal = {
        canister_id: IC.canister_id;
        seq: Nat;
        proposer: Principal;
        proposal_type: ProposalType;
        permission_change: ?PermissionChange; // not null if proposal_type is permission
        canister_operation: CanisterOperation;
        status: ProposalStatus;
        code: ?Blob; // not null if proposal_type is operation and canister_operation is #installCode or #upgradeCode or #reinstallCode
        approvers: [Principal];
        disapprovers: [Principal];
        required_approvals: Nat;
        total_voters: Nat;
    };

    public type ProposalType = {
        #permission;
        #operation;
    };

    public type PermissionChange = {
        #requireMultiSig;
        #requireSingleSig;
    };

    public type CanisterOperation = {
        #installCode;
        #upgradeCode;
        #reinstallCode;
		#uninstallCode;
		#startCanister;
		#stopCanister;
		#deleteCanister;
	};

    public type ProposalStatus = {
        #pending;
        #approved;
        #disapproved;
    };

    let OPS_REQUIRING_CODE = [
        #installCode,
        #upgradeCode,
        #reinstallCode,
    ];

    public func create_proposal(
        canister_id: IC.canister_id,
        seq: Nat,
        proposer: Principal,
        proposal_type: ProposalType,
        permission_change: ?PermissionChange,
        canister_operation: CanisterOperation,
        code: ?Blob,
        required_approvals: Nat,
        total_voters: Nat
    ): Proposal {
        // no point to create a proposal if requiring only one approval
        assert(required_approvals > 1 and required_approvals <= total_voters);
        if (proposal_type == #permission) {
            assert(permission_change != null);
        } else {
            assert(permission_change == null);
        };
        if (code_required(proposal_type, canister_operation)) {
            assert(code != null);
        } else {
            assert(code == null);
        };
        {
            canister_id = canister_id;
            seq = seq;
            proposer = proposer;
            proposal_type = proposal_type;
            permission_change = permission_change;
            canister_operation = canister_operation;
            status = #pending;
            code = code;
            approvers = [proposer];
            disapprovers = [];
            required_approvals = required_approvals;
            total_voters = total_voters;
        };
    };

    public func approve_propsal(approver: Principal, proposal: Proposal): Proposal {
        assert(proposal.status == #pending);
        assert(not already_approved(approver, proposal));
        assert(not already_disapproved(approver, proposal));
        let new_approvers = Array.append(proposal.approvers, [approver]);
        let new_status: ProposalStatus = if (new_approvers.size() >= proposal.required_approvals) {
            #approved
        } else {
            #pending
        };
        {
            canister_id = proposal.canister_id;
            seq = proposal.seq;
            proposal_type = proposal.proposal_type;
            permission_change = proposal.permission_change;
            proposer = proposal.proposer;
            canister_operation = proposal.canister_operation;
            status = new_status;
            code = proposal.code;
            approvers = new_approvers;
            disapprovers = proposal.disapprovers;
            required_approvals = proposal.required_approvals;
            total_voters = proposal.total_voters;
        };
    };

    public func disapprove_proposal(disapprover: Principal, proposal: Proposal): Proposal {
        assert(proposal.status == #pending);
        assert(not already_approved(disapprover, proposal));
        assert(not already_disapproved(disapprover, proposal));
        let new_disapprovers = Array.append(proposal.disapprovers, [disapprover]);
        let new_status: ProposalStatus = if (new_disapprovers.size() + proposal.required_approvals > proposal.total_voters) {
            #disapproved
        } else {
            #pending
        };
        {
            canister_id = proposal.canister_id;
            seq = proposal.seq;
            proposer = proposal.proposer;
            proposal_type = proposal.proposal_type;
            permission_change = proposal.permission_change;
            canister_operation = proposal.canister_operation;
            status = new_status;
            code = proposal.code;
            approvers = proposal.approvers;
            disapprovers = new_disapprovers;
            required_approvals = proposal.required_approvals;
            total_voters = proposal.total_voters;
        };
    };

    private func code_required(t: ProposalType, o: CanisterOperation): Bool {
        if (t == #permission) {
            false // code is NOT required if the proposal is about permission change
        } else {
            switch(Array.find(OPS_REQUIRING_CODE, func (a: CanisterOperation): Bool { a == o })) {
                case (null) { false }; 
                case (_) { true };
            }
        }
    };

    private func already_approved(approver: Principal, proposal: Proposal): Bool {
        for (a in proposal.approvers.vals()) {
            if (Principal.equal(a, approver)) {
                return true;
            };
        };
        false
    };

    private func already_disapproved(disapprover: Principal, proposal: Proposal): Bool {
        for (d in proposal.disapprovers.vals()) {
            if (Principal.equal(d, disapprover)) {
                return true;
            };
        };
        false
    };
}