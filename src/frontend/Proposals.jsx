import React, { useState, useEffect } from 'react';
import Proposal from './Proposal';

const Proposals = (props) => {
    const {proposals} = props;

    return (
        <>
            <h3>Proposals</h3>
            <ol>{proposals.map(proposal => (<Proposal key={proposal.seq} proposal={proposal}/>))}</ol>
        </>
    )
}

export default Proposals;