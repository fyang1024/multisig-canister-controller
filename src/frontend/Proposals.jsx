import React from 'react';
import Proposal from './Proposal';

const Proposals = (props) => {
    const {proposals, canisterId} = props;

    return (
        <>
            <h3>Proposals</h3>
            <ol>{proposals.map(proposal => (<Proposal key={proposal.seq} proposal={proposal} canisterId={canisterId}/>))}</ol>
        </>
    )
}

export default Proposals;