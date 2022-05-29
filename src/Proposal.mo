import IC "./ic";
import Array "mo:base/Array";
import Principal "mo:base/Principal"

module {

    public type ProposalType = {
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
        #executed;
    };

    public type Proposal = {
        canister_id: IC.canister_id;
        seq: Nat;
        proposer: Principal;
        proposal_type: ProposalType;
        status: ProposalStatus;
        content: ?Blob; // not null if type is #installCode or #upgradeCode or #reinstallCode
        approvers: [Principal];
        disapprovers: [Principal];
        required_approvals: Nat;
        total_voters: Nat;
    };

    let TYPES_REQUIRING_CONTENT = [
        #installCode,
        #upgradeCode,
        #reinstallCode,
    ];

    public func create_proposal(
        seq: Nat,
        proposer: Principal,
        proposal_type: ProposalType,
        canister_id: IC.canister_id,
        content: ?Blob,
        required_approvals: Nat,
        total_voters: Nat
    ): Proposal {
        assert(required_approvals > 0 and required_approvals <= total_voters);
        if (content_required(proposal_type)) {
            assert(content != null);
        } else {
            assert(content == null);
        };
        let status = if (required_approvals == 1) {
            #approved
        } else {
            #pending
        };
        {
            canister_id = canister_id;
            seq = seq;
            proposer = proposer;
            proposal_type = proposal_type;
            status = status;
            content = content;
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
        let new_status: ProposalStatus = if (proposal.approvers.size() + 1 >= proposal.required_approvals) {
            #approved
        } else {
            #pending
        };
        {
            canister_id = proposal.canister_id;
            seq = proposal.seq;
            proposer = proposal.proposer;
            proposal_type = proposal.proposal_type;
            status = new_status;
            content = proposal.content;
            approvers = Array.append(proposal.approvers, [approver]);
            disapprovers = proposal.disapprovers;
            required_approvals = proposal.required_approvals;
            total_voters = proposal.total_voters;
        };
    };

    public func disapprove_proposal(disapprover: Principal, proposal: Proposal): Proposal {
        assert(proposal.status == #pending);
        assert(not already_approved(disapprover, proposal));
        assert(not already_disapproved(disapprover, proposal));
        let new_status: ProposalStatus = if (proposal.disapprovers.size() + 1 > proposal.total_voters - proposal.required_approvals) {
            #disapproved
        } else {
            #pending
        };
        {
            canister_id = proposal.canister_id;
            seq = proposal.seq;
            proposer = proposal.proposer;
            proposal_type = proposal.proposal_type;
            status = new_status;
            content = proposal.content;
            approvers = proposal.approvers;
            disapprovers = Array.append(proposal.disapprovers, [disapprover]);
            required_approvals = proposal.required_approvals;
            total_voters = proposal.total_voters;
        };
    };

    private func content_required(t: ProposalType): Bool {
        switch(Array.find(TYPES_REQUIRING_CONTENT, func (a: ProposalType): Bool { a == t })) {
            case (null) { false };
            case (_) { true };
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