import React, { useState, useEffect } from 'react';
import { backend } from "../declarations/backend";
import Canister from './Canister';

const Canisters = () => {
    const [canisters, setCanisters] = useState([]);

    useEffect(() => {
        const retrieveCanisters = async () => {
            const canisters = await backend.get_canisters();
            setCanisters(canisters);
        };
        retrieveCanisters();
    }, []);

    return (
        <>
            <h1>Canisters</h1>
            <ul>{canisters.map(canister => (<Canister key={canister.id} canister={canister} />))}</ul>
        </>
    )
}

export default Canisters;