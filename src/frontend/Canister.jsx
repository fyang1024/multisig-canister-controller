import React, { useState, useEffect, useContext } from 'react';
import { IdentityContext } from './IdentityContext';
import Proposals from './Proposals';

const Canister = (props) => {
    const { canister } = props;
    const [status, setStatus] = useState();
    const { actor } = useContext(IdentityContext);

    useEffect(() => {
        const retrieveCanisterStatus = async () => {
            const status = await actor.get_canister_status(canister.id);
            setStatus(status);
        };
        retrieveCanisterStatus();
    }, [actor, canister.id]);

    if (status) {
        return <li>
            <div>ID: {canister.id.toString()}</div>
            <div>Status: {Object.keys(status.status)[0]}</div>
            <div>Freezing Threshold: {status.freezing_threshold.toString()}</div>
            <div>Memory Size: {status.memory_size.toString()}</div>
            <div>Cycles: {status.cycles.toString()}</div>
            <div>Module Hash: {status.module_hash}</div>
            <div>Memory Allocation: {status.settings.memory_allocation.toString()}</div>
            <div>Compute Allocation: {status.settings.compute_allocation.toString()}</div>
            <Proposals proposals={canister.proposals} />
        </li>;
    } else {
        return <li>
            <div>ID: {canister.id.toString()}</div>
        </li>;
    }
}

export default Canister;