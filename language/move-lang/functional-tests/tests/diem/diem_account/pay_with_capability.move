//! account: alice
//! account: bob
//! account: carol

//! sender: alice
module AlicePays {
    use 0x1::Coin1::Coin1;
    use 0x1::DiemAccount;

    resource struct T {
        cap: DiemAccount::WithdrawCapability,
    }

    public fun create(sender: &signer) {
        move_to(sender, T {
            cap: DiemAccount::extract_withdraw_capability(sender),
        })
    }

    public fun pay(payee: address, amount: u64) acquires T {
        let t = borrow_global<T>({{alice}});
        DiemAccount::pay_from<Coin1>(
            &t.cap,
            payee,
            amount,
            x"0A11CE",
            x""
        )
    }
}

// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: alice
script {
use {{alice}}::AlicePays;
fun main(sender: &signer) {
    AlicePays::create(sender)
}
}

// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: bob
script {
use {{alice}}::AlicePays;
use 0x1::Coin1::Coin1;
use 0x1::DiemAccount;

fun main() {
    let carol_prev_balance = DiemAccount::balance<Coin1>({{carol}});
    let alice_prev_balance = DiemAccount::balance<Coin1>({{alice}});
    AlicePays::pay({{carol}}, 10);
    assert(carol_prev_balance + 10 == DiemAccount::balance<Coin1>({{carol}}), 0);
    assert(alice_prev_balance - 10 == DiemAccount::balance<Coin1>({{alice}}), 1);
}
}
// check: "Keep(EXECUTED)"
