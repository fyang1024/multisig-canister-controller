import React, { useState, useEffect } from 'react';
import { backend } from "../declarations/backend";

const Owners = () => {
    const [owners, setOwners] = useState([]);

    useEffect(() => {
        const retrieveOwners = async () => {
            const owners = await backend.get_owners();
            setOwners(owners);
        };
        retrieveOwners();
    }, []);

    return (
        <>
            <h1>Owners</h1>
            <ul>{owners.map(owner => (<li key={owner}>{owner.toString()}</li>))}</ul>
        </>
    )
}

export default Owners;