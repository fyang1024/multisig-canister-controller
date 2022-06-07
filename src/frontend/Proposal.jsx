import React, { useState, useEffect } from 'react';

const Proposal = (props) => {
    const {proposal} = props;

    return (
        <>
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
        </>
    )
}

export default Proposal;