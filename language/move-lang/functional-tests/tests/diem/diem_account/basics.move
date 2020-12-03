//! account: bob, 10000XDM
//! account: alice, 0XDM
//! account: abby, 0, 0, address
//! account: doris, 0Coin1, 0

module Holder {
    use 0x1::Signer;

    resource struct Hold<T> {
        x: T
    }

    public fun hold<T>(account: &signer, x: T) {
        move_to(account, Hold<T>{x})
    }

    public fun get<T>(account: &signer): T
    acquires Hold {
        let Hold {x} = move_from<Hold<T>>(Signer::address_of(account));
        x
    }
}

//! new-transaction
script {
    use 0x1::DiemAccount;
    fun main(sender: &signer) {
        DiemAccount::initialize(sender, x"00000000000000000000000000000000");
    }
}
// check: "Keep(ABORTED { code: 1,"

//! new-transaction
//! sender: bob
script {
    use 0x1::XDM::XDM;
    use 0x1::DiemAccount;
    fun main(account: &signer) {
        let with_cap = DiemAccount::extract_withdraw_capability(account);
        DiemAccount::pay_from<XDM>(&with_cap, {{bob}}, 10, x"", x"");
        DiemAccount::restore_withdraw_capability(with_cap);
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: bob
script {
    use 0x1::XDM::XDM;
    use 0x1::DiemAccount;
    fun main(account: &signer) {
        let with_cap = DiemAccount::extract_withdraw_capability(account);
        DiemAccount::pay_from<XDM>(&with_cap, {{abby}}, 10, x"", x"");
        DiemAccount::restore_withdraw_capability(with_cap);
    }
}
// check: "Keep(ABORTED { code: 4357,"

//! new-transaction
//! sender: bob
script {
    use 0x1::Coin1::Coin1;
    use 0x1::DiemAccount;
    fun main(account: &signer) {
        let with_cap = DiemAccount::extract_withdraw_capability(account);
        DiemAccount::pay_from<Coin1>(&with_cap, {{abby}}, 10, x"", x"");
        DiemAccount::restore_withdraw_capability(with_cap);
    }
}
// check: "Keep(ABORTED { code: 4869,"

//! new-transaction
//! sender: bob
script {
    use 0x1::XDM::XDM;
    use 0x1::DiemAccount;
    fun main(account: &signer) {
        let with_cap = DiemAccount::extract_withdraw_capability(account);
        DiemAccount::pay_from<XDM>(&with_cap, {{doris}}, 10, x"", x"");
        DiemAccount::restore_withdraw_capability(with_cap);
    }
}
// check: "Keep(ABORTED { code: 4615,"

//! new-transaction
//! sender: bob
script {
    use 0x1::DiemAccount;
    fun main(account: &signer) {
        let rot_cap = DiemAccount::extract_key_rotation_capability(account);
        DiemAccount::rotate_authentication_key(&rot_cap, x"123abc");
        DiemAccount::restore_key_rotation_capability(rot_cap);
    }
}
// check: "Keep(ABORTED { code: 2055,"

//! new-transaction
script {
    use 0x1::DiemAccount;
    use {{default}}::Holder;
    fun main(account: &signer) {
        Holder::hold(
            account,
            DiemAccount::extract_key_rotation_capability(account)
        );
        Holder::hold(
            account,
            DiemAccount::extract_key_rotation_capability(account)
        );
    }
}
// check: "Keep(ABORTED { code: 2305,"

//! new-transaction
script {
    use 0x1::DiemAccount;
    use 0x1::Signer;
    fun main(sender: &signer) {
        let cap = DiemAccount::extract_key_rotation_capability(sender);
        assert(
            *DiemAccount::key_rotation_capability_address(&cap) == Signer::address_of(sender), 0
        );
        DiemAccount::restore_key_rotation_capability(cap);
        let with_cap = DiemAccount::extract_withdraw_capability(sender);

        assert(
            *DiemAccount::withdraw_capability_address(&with_cap) == Signer::address_of(sender),
            0
        );
        DiemAccount::restore_withdraw_capability(with_cap);
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: bob
script {
    use 0x1::DiemAccount;
    use 0x1::XDM::XDM;
    fun main(account: &signer) {
        let with_cap = DiemAccount::extract_withdraw_capability(account);
        DiemAccount::pay_from<XDM>(&with_cap, {{alice}}, 10000, x"", x"");
        DiemAccount::restore_withdraw_capability(with_cap);
        assert(DiemAccount::balance<XDM>({{alice}}) == 10000, 60)
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: blessed
//! type-args: 0x1::Coin1::Coin1
//! args: 0, 0x0, {{bob::auth_key}}, b"bob", true
stdlib_script::create_parent_vasp_account
// check: "Keep(ABORTED { code: 2567,"

//! new-transaction
//! sender: blessed
//! type-args: 0x1::Coin1::Coin1
//! args: 0, {{abby}}, x"", b"bob", true
stdlib_script::create_parent_vasp_account
// check: "Keep(ABORTED { code: 2055,"

//! new-transaction
script {
use 0x1::DiemAccount;
fun main() {
    DiemAccount::sequence_number(0x1);
}
}
// check: "Keep(ABORTED { code: 5,"

//! new-transaction
script {
use 0x1::DiemAccount;
fun main() {
    DiemAccount::authentication_key(0x1);
}
}
// check: "Keep(ABORTED { code: 5,"

//! new-transaction
script {
use 0x1::DiemAccount;
fun main() {
    DiemAccount::delegated_key_rotation_capability(0x1);
}
}
// check: "Keep(ABORTED { code: 5,"

//! new-transaction
script {
use 0x1::DiemAccount;
fun main() {
    DiemAccount::delegated_withdraw_capability(0x1);
}
}
// check: "Keep(ABORTED { code: 5,"
