//! account: alice
//! account: bob

//! sender: alice
script {
use 0x1::Coin1::Coin1;
use 0x1::DiemAccount;
// send a transaction with metadata and make sure we see it in the PaymentReceivedEvent
fun main(account: &signer) {
    let with_cap = DiemAccount::extract_withdraw_capability(account);
    DiemAccount::pay_from<Coin1>(&with_cap, {{bob}}, 1000, x"deadbeef", x"");
    DiemAccount::restore_withdraw_capability(with_cap);
}
}

// check: SentPaymentEvent
// check: deadbeef
// check: ReceivedPaymentEvent
// check: deadbeef
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: alice
script {
use 0x1::DiemAccount;
use 0x1::Coin1::Coin1;
// same thing, but using "deposit_with_metadata" API
fun main(account: &signer) {
    let with_cap = DiemAccount::extract_withdraw_capability(account);
    DiemAccount::pay_from<Coin1>(
        &with_cap,
        {{bob}},
        100,
        x"deadbeef",
        x""
    );
    DiemAccount::restore_withdraw_capability(with_cap);
}
}

// check: SentPaymentEvent
// check: deadbeef
// check: ReceivedPaymentEvent
// check: deadbeef
// check: "Keep(EXECUTED)"
