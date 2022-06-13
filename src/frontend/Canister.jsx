import React, { useState, useEffect, useContext } from 'react';
import { IdentityContext } from './IdentityContext';
import Proposals from './Proposals';
import { sha256 } from 'js-sha256';
import { useFilePicker } from 'use-file-picker';

const Canister = (props) => {
    const { canister } = props;
    const [error, setError] = useState();
    const [processing, setProcessing] = useState(false);
    const [status, setStatus] = useState();
    const { identity, actor } = useContext(IdentityContext);

    const [openFileSelector, { filesContent }] = useFilePicker({
        accept: '.wasm',
        multiple: false,
        readAs: "ArrayBuffer"
      });

    const retrieveCanisterStatus = async () => {
        const status = await actor.get_canister_status(canister.id);
        setStatus(status);
    };

    useEffect(() => {
        retrieveCanisterStatus();
    }, [actor, canister.id]);

    const stopCanister = async () => {
        try {
            setProcessing(true);
            await actor.stop_canister(canister.id.toString());
            await retrieveCanisterStatus();
            setProcessing(false);
        } catch(e) {
            setProcessing(false);
            setError(e);
        }
    };

    const deleteCanister = async () => {
        try {
            setProcessing(true);
            await actor.delete_canister(canister.id.toString());
            await retrieveCanisterStatus();
            setProcessing(false);
        } catch(e) {
            setProcessing(false);
            setError(e);
        }
    };

    const startCanister = async () => {
        try {
            setProcessing(true);
            await actor.start_canister(canister.id.toString());
            await retrieveCanisterStatus();
            setProcessing(false);
        } catch(e) {
            setProcessing(false);
            setError(e);
        }
    };

    const installCode = async () => {
        try {
            setProcessing(true);
            await actor.install_code(new Uint8Array(filesContent[0].content), canister.id.toString());
            await retrieveCanisterStatus();
            setProcessing(false);
        } catch(e) {
            setProcessing(false);
            setError(e);
        }
    };

    const upgradeCode = async () => {
        try {
            setProcessing(true);
            await actor.upgrade_code(new Uint8Array(filesContent[0].content), canister.id.toString());
            await retrieveCanisterStatus();
            setProcessing(false);
        } catch(e) {
            setProcessing(false);
            setError(e);
        }
    };

    const codeInstalled = () => {
        return status && status.module_hash && status.module_hash.length;
    };

    const codeReady = () => {
        return filesContent && filesContent.length && filesContent[0].content;
    };

    if (status) {
        return <li>
            {error && <p>{error.toString()}</p>}
            <div>ID: {canister.id.toString()}</div>
            <div>
                Status: {Object.keys(status.status)[0]}
                {identity && Object.keys(status.status)[0] == 'running' && <button disabled={processing} onClick={stopCanister}>Stop</button>}
                {identity && Object.keys(status.status)[0] == 'stopped' && <button disabled={processing} onClick={deleteCanister}>Delete</button>}
                {identity && Object.keys(status.status)[0] == 'stopped' && <button disabled={processing} onClick={startCanister}>Start</button>}
            </div>
            <div>Freezing Threshold: {status.freezing_threshold.toString()}</div>
            <div>Memory Size: {status.memory_size.toString()}</div>
            <div>Cycles: {status.cycles.toString()}</div>
            <div>
                Module Hash: {status.module_hash}
                {identity && 
                <>
                    <button onClick={() => openFileSelector()}>Choose WASM file</button>
                    {filesContent.map((file) => (<span key={file.name}>{file.name} SHA256: {sha256(file.content)}</span>))}
                    {codeInstalled() && <button disabled={processing || !codeReady()} onClick={upgradeCode}>Upgrade Code</button>}
                    {!codeInstalled() && <button disabled={processing || !codeReady()} onClick={installCode}>Install Code</button>}
                </>}
            </div>
            <div>Memory Allocation: {status.settings.memory_allocation.toString()}</div>
            <div>Compute Allocation: {status.settings.compute_allocation.toString()}</div>
            <Proposals proposals={canister.proposals} canisterId={canister.id}/>
        </li>;
    } else {
        return <li>
            <div>ID: {canister.id.toString()}</div>
        </li>;
    }
}

export default Canister;