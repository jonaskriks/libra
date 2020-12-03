//! account: alice, 0, 0, 0Coin1

script {
use 0x1::Coin1::Coin1;
use 0x1::DiemAccount;
use 0x1::Signer;

fun main(account: &signer) {
    let addr = Signer::address_of(account);
    let sender_balance = DiemAccount::balance<Coin1>(addr);
    let with_cap = DiemAccount::extract_withdraw_capability(account);
    DiemAccount::pay_from<Coin1>(&with_cap, {{alice}}, sender_balance, x"", x"");

    assert(DiemAccount::balance<Coin1>(addr) == 0, 42);

    DiemAccount::pay_from<Coin1>(&with_cap, {{alice}}, sender_balance, x"", x"");
    DiemAccount::restore_withdraw_capability(with_cap);
}
}
// check: "Keep(ABORTED { code: 1288,"
