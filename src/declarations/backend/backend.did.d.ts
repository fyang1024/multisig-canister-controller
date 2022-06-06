import type { Principal } from '@dfinity/principal';
export type CanisterOperation = { 'stopCanister' : null } |
  { 'upgradeCode' : null } |
  { 'installCode' : null } |
  { 'reinstallCode' : null } |
  { 'uninstallCode' : null } |
  { 'startCanister' : null } |
  { 'deleteCanister' : null };
export interface MultisigCanisterController {
  'create_canister' : () => Promise<canister_id>,
  'delete_canister' : (arg_0: canister_id) => Promise<undefined>,
  'get_last_proposal' : (arg_0: canister_id) => Promise<[] | [Proposal]>,
  'get_minimal_sigs' : () => Promise<bigint>,
  'get_owners' : () => Promise<Array<Principal>>,
  'init' : (arg_0: Array<Principal>, arg_1: bigint) => Promise<undefined>,
  'install_code' : (arg_0: Array<number>, arg_1: canister_id) => Promise<
      undefined
    >,
  'propose' : (
      arg_0: ProposalType,
      arg_1: [] | [PermissionChange],
      arg_2: CanisterOperation,
      arg_3: canister_id,
      arg_4: [] | [Array<number>],
    ) => Promise<undefined>,
  'reinstall_code' : (arg_0: Array<number>, arg_1: canister_id) => Promise<
      undefined
    >,
  'start_canister' : (arg_0: canister_id) => Promise<undefined>,
  'stop_canister' : (arg_0: canister_id) => Promise<undefined>,
  'uninstall_code' : (arg_0: canister_id) => Promise<undefined>,
  'upgrade_code' : (arg_0: Array<number>, arg_1: canister_id) => Promise<
      undefined
    >,
  'vote_against_last_proposal' : (arg_0: canister_id) => Promise<undefined>,
  'vote_for_last_proposal' : (arg_0: canister_id) => Promise<undefined>,
}
export type PermissionChange = { 'requireMultiSig' : null } |
  { 'requireSingleSig' : null };
export interface Proposal {
  'seq' : bigint,
  'status' : ProposalStatus,
  'permission_change' : [] | [PermissionChange],
  'code' : [] | [Array<number>],
  'canister_id' : canister_id,
  'required_approvals' : bigint,
  'total_voters' : bigint,
  'proposer' : Principal,
  'canister_operation' : CanisterOperation,
  'disapprovers' : Array<Principal>,
  'proposal_type' : ProposalType,
  'approvers' : Array<Principal>,
  'code_hash' : [] | [Array<number>],
}
export type ProposalStatus = { 'pending' : null } |
  { 'disapproved' : null } |
  { 'approved' : null };
export type ProposalType = { 'permission' : null } |
  { 'operation' : null };
export type canister_id = Principal;
export interface _SERVICE extends MultisigCanisterController {}
