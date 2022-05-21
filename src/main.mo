import IC "./ic";
import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Principal "mo:base/Principal";

shared(msg) actor class () = self {

    private var owners: [Principal] = [];
    private var minimal_sigs: Nat = 0;

    public func init(o: [Principal], m: Nat) {
        assert(m > 0 and m <= o.size());
        owners := o;
        minimal_sigs := m;
    };

    public query func get_owners(): async [Principal] {
        owners
    };

    public query func get_minimal_sigs(): async Nat {
        minimal_sigs
    };

    public shared (msg) func create_canister() : async IC.canister_id {
        assert(is_one_of_owners(msg.caller));
        let settings = {
            freezing_threshold = null;
            controllers = ?[Principal.fromActor(self)];
            memory_allocation = null;
            compute_allocation = null;
        };
        let ic: IC.Self = actor("aaaaa-aa");
        let result = await ic.create_canister({ settings = ?settings });
        result.canister_id
    };

    public shared (msg) func install_code(code: Blob, canister_id: IC.canister_id): async () {
        assert(is_one_of_owners(msg.caller));
        let ic: IC.Self = actor("aaaaa-aa");
        await ic.install_code({ 
            arg = [];
            wasm_module = Blob.toArray(code);
            mode = #install;
            canister_id = canister_id;
        });
    };

    public shared (msg) func start_canister(canister_id: IC.canister_id): async () {
        assert(is_one_of_owners(msg.caller));
        let ic: IC.Self = actor("aaaaa-aa");
        await ic.start_canister({ canister_id = canister_id });
    };

    public shared (msg) func stop_canister(canister_id: IC.canister_id): async () {
        assert(is_one_of_owners(msg.caller));
        let ic: IC.Self = actor("aaaaa-aa");
        await ic.stop_canister({ canister_id = canister_id });
    };

    public shared (msg) func delete_canister(canister_id: IC.canister_id): async () {
        assert(is_one_of_owners(msg.caller));
        let ic: IC.Self = actor("aaaaa-aa");
        await ic.delete_canister({ canister_id = canister_id });
    };

    private func is_one_of_owners(p: Principal): Bool {
        switch(Array.find(owners, func (a: Principal): Bool { Principal.equal(a, p) })) {
            case (null) { false };
            case (_) { true };
        }
    }
}
