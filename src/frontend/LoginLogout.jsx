import React, { useContext } from 'react';
import { AuthClient } from "@dfinity/auth-client";
import { Actor, HttpAgent } from "@dfinity/agent";
import { IdentityContext } from './IdentityContext';
import { backend, idlFactory, canisterId } from "../declarations/backend";

const LoginLogout = () => {
    const {identity, setIdentity, setActor} = useContext(IdentityContext);

    const ii = process.env.NODE_ENV === "production" ? 
        "https://identity.ic0.app/" : 
        "http://localhost:8000/?canisterId=rwlgt-iiaaa-aaaaa-aaaaa-cai";

    const login = async () => {
        let authClient = await AuthClient.create();
        authClient.login({
            identityProvider: ii,
            maxTimeToLive: BigInt(24) * BigInt(3_600_000_000_000),
            onSuccess: async () => {
                const identity = await authClient.getIdentity();
                console.log("identity", identity.getPrincipal().toString());
                setIdentity(identity);
                agent = new HttpAgent({ identity });
                if (process.env.NODE_ENV !== "production") {
                    agent.fetchRootKey().catch((err) => console.log);
                }
                setActor(Actor.createActor(idlFactory, {agent, canisterId}));
            }
        });
    };

    const logout = async () => {
        setIdentity(null);
        setActor(backend);
    };

    if (identity) {
        return <button onClick={logout}>Logout</button>;
    } else {
        return <button onClick={login}>Login</button>;
    }
};

export default LoginLogout;