# Multisig Canister Controller

The multisig canister controller allows any of the M members to 
* create canister
* install code
* start canister
* stop canister
* delete canister, and
* upgrade canister only if M members agree

## Running the project locally

If you want to test your project locally, you can use the following commands:

```bash
# Starts the replica, running in the background
dfx start --background

# Deploys your canisters to the replica and generates your candid interface
dfx deploy
```

Once the job completes, your application will be available at `http://localhost:8000?canisterId={asset_canister_id}`.

The canisters are deployed to mainnet now. 
URLs:
  Frontend:
    frontend: https://amgcj-mqaaa-aaaag-aak6q-cai.ic0.app/
  Candid:
    backend: https://a4gq6-oaaaa-aaaab-qaa4q-cai.raw.ic0.app/?id=alhe5-biaaa-aaaag-aak6a-cai
