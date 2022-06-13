import React, { useState, useEffect, useContext } from 'react';
import { IdentityContext } from './IdentityContext';

const Owners = () => {
    const [owners, setOwners] = useState([]);
    const { actor } = useContext(IdentityContext);

    useEffect(() => {
        const retrieveOwners = async () => {
            const owners = await actor.get_owners();
            setOwners(owners);
        };
        retrieveOwners();
    }, [actor]);

    return (
        <>
            <h1>Owners</h1>
            <ul>{owners.map(owner => (<li key={owner}>{owner.toString()}</li>))}</ul>
        </>
    );
}

export default Owners;