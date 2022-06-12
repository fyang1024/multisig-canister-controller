import React, { useState, useEffect, useContext } from 'react';
import { IdentityContext } from './IdentityContext';
import Canister from './Canister';

const Canisters = () => {
    const [error, setError] = useState();
    const [processing, setProcessing] = useState(false);
    const [canisters, setCanisters] = useState([]);
    const { identity, actor } = useContext(IdentityContext);

    useEffect(() => {
        const retrieveCanisters = async () => {
            const canisters = await actor.get_canisters();
            setCanisters(canisters);
        };
        retrieveCanisters();
    }, []);

    const createCanister = async () => {
        try {
            setProcessing(true);
            await actor.create_canister();
            setProcessing(false);
        } catch(e) {
            setProcessing(false);
            setError(e);
        }
    };

    return (
        <>
            {error && <p>Error: {error.toString()}</p>}
            <h1>Canisters {identity && <button disabled={processing} onClick={createCanister}>Create new canister</button>}</h1>
            <ul>{canisters.map(canister => (<Canister key={canister.id} canister={canister} />))}</ul>
        </>
    )
}

export default Canisters;