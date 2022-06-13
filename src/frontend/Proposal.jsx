import React, { useContext, useState } from 'react';
import { IdentityContext } from './IdentityContext';

const Proposal = (props) => {
    const {proposal, canisterId} = props;
    const [error, setError] = useState();
    const [processing, setProcessing] = useState(false);
    const { identity, actor } = useContext(IdentityContext);
    const pending = () => Object.keys(proposal.proposal_type)[0] === 'pending';
    const notVoted = () => {
        return identity && 
        !proposal.approvers.find(approver => approver.toString() === identity.getPrincipal().toString()) &&
        !proposal.disapprovers.find(disapprover => disapprover.toString() === identity.getPrincipal().toString());
    };

    const approve = async () => {
        try {
            setProcessing(true);
            await actor.vote_for_last_proposal(canisterId);
            location.reload(); // reload the page to retrieve updated data, as there is no interface to retrieve a single proposal
        } catch(e) {
            setProcessing(false);
            setError(e);
        }
    };

    const disapprove = async () => {
        try {
            setProcessing(true);
            await actor.vote_against_last_proposal(canisterId);
            location.reload(); // reload the page to retrieve updated data, as there is no interface to retrieve a single proposal
        } catch(e) {
            setProcessing(false);
            setError(e);
        }
    };

    return (
        <li>
            {error && <p>{error.toString()}</p>}
            <div>Proposer: {proposal.proposer.toString()}</div>
            <div>Type: {Object.keys(proposal.proposal_type)[0]}</div>
            {proposal.permission_change && <div>Permission Change: {Object.keys(proposal.permission_change[0])[0]}</div>}
            <div>Operation: {Object.keys(proposal.canister_operation)[0]}</div>
            <div>Status: {Object.keys(proposal.status)[0]}</div>
            <div>Total Voters: {proposal.total_voters.toString()}</div>
            <div>Required Approvals: {proposal.required_approvals.toString()}</div>
            {proposal.code_hash && <div>Code Hash: {proposal.code_hash}</div>}
            <div>Approvers:</div>
            <ul>{proposal.approvers.map((approver)=><li key={approver}>{approver.toString()}</li>)}</ul>
            <div>Disapprovers:</div>
            <ul>{proposal.disapprovers.map((disapprover)=><li key={disapprover}>{disapprover.toString()}</li>)}</ul>
            {identity && pending() && notVoted() && 
            <>
                <div><button disabled={processing} onClick={approve}>Approve</button></div>
                <div><button disabled={processing} onClick={disapprove}>Disapprove</button></div>
            </>}
        </li>
    )
}

export default Proposal;