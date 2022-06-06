export const idlFactory = ({ IDL }) => {
  const canister_id = IDL.Principal;
  const ProposalStatus = IDL.Variant({
    'pending' : IDL.Null,
    'disapproved' : IDL.Null,
    'approved' : IDL.Null,
  });
  const PermissionChange = IDL.Variant({
    'requireMultiSig' : IDL.Null,
    'requireSingleSig' : IDL.Null,
  });
  const CanisterOperation = IDL.Variant({
    'stopCanister' : IDL.Null,
    'upgradeCode' : IDL.Null,
    'installCode' : IDL.Null,
    'reinstallCode' : IDL.Null,
    'uninstallCode' : IDL.Null,
    'startCanister' : IDL.Null,
    'deleteCanister' : IDL.Null,
  });
  const ProposalType = IDL.Variant({
    'permission' : IDL.Null,
    'operation' : IDL.Null,
  });
  const Proposal = IDL.Record({
    'seq' : IDL.Nat,
    'status' : ProposalStatus,
    'permission_change' : IDL.Opt(PermissionChange),
    'code' : IDL.Opt(IDL.Vec(IDL.Nat8)),
    'canister_id' : canister_id,
    'required_approvals' : IDL.Nat,
    'total_voters' : IDL.Nat,
    'proposer' : IDL.Principal,
    'canister_operation' : CanisterOperation,
    'disapprovers' : IDL.Vec(IDL.Principal),
    'proposal_type' : ProposalType,
    'approvers' : IDL.Vec(IDL.Principal),
    'code_hash' : IDL.Opt(IDL.Vec(IDL.Nat8)),
  });
  const MultisigCanisterController = IDL.Service({
    'create_canister' : IDL.Func([], [canister_id], []),
    'delete_canister' : IDL.Func([canister_id], [], []),
    'get_last_proposal' : IDL.Func(
        [canister_id],
        [IDL.Opt(Proposal)],
        ['query'],
      ),
    'get_minimal_sigs' : IDL.Func([], [IDL.Nat], ['query']),
    'get_owners' : IDL.Func([], [IDL.Vec(IDL.Principal)], ['query']),
    'init' : IDL.Func([IDL.Vec(IDL.Principal), IDL.Nat], [], ['oneway']),
    'install_code' : IDL.Func([IDL.Vec(IDL.Nat8), canister_id], [], []),
    'propose' : IDL.Func(
        [
          ProposalType,
          IDL.Opt(PermissionChange),
          CanisterOperation,
          canister_id,
          IDL.Opt(IDL.Vec(IDL.Nat8)),
        ],
        [],
        ['oneway'],
      ),
    'reinstall_code' : IDL.Func([IDL.Vec(IDL.Nat8), canister_id], [], []),
    'start_canister' : IDL.Func([canister_id], [], []),
    'stop_canister' : IDL.Func([canister_id], [], []),
    'uninstall_code' : IDL.Func([canister_id], [], []),
    'upgrade_code' : IDL.Func([IDL.Vec(IDL.Nat8), canister_id], [], []),
    'vote_against_last_proposal' : IDL.Func([canister_id], [], ['oneway']),
    'vote_for_last_proposal' : IDL.Func([canister_id], [], []),
  });
  return MultisigCanisterController;
};
export const init = ({ IDL }) => { return []; };
