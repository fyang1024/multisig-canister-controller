import React, { useState, useEffect, useContext } from 'react';
import { IdentityContext } from './IdentityContext';
import Canister from './Canister';

const Canisters = () => {
    const [error, setError] = useState();
    const [processing, setProcessing] = useState(false);
    const [canisters, setCanisters] = useState([]);
    const { identity, actor } = useContext(IdentityContext);

    const retrieveCanisters = async () => {
        const canisters = await actor.get_canisters();
        setCanisters(canisters);
    };

    useEffect(() => {
        retrieveCanisters();
    }, []);

    const createCanister = async () => {
        try {
            setProcessing(true);
            await actor.create_canister();
            await retrieveCanisters();
            setProcessing(false);
        } catch(e) {
            setProcessing(false);
            setError(e);
        }
    };

    return (
        <>
            {error && <p>{error.toString()}</p>}
            <h1>Canisters {identity && <button disabled={processing} onClick={createCanister}>Create new canister</button>}</h1>
            <ul>{canisters.map(canister => (<Canister key={canister.id} canister={canister} />))}</ul>
        </>
    )
}

export default Canisters;