script {
use 0x1::Coin1::Coin1;
use 0x1::DiemAccount;
use 0x1::Signer;

fun main(account: &signer) {
    let addr = Signer::address_of(account);
    let old_balance = DiemAccount::balance<Coin1>(addr);

    let with_cap = DiemAccount::extract_withdraw_capability(account);
    DiemAccount::pay_from<Coin1>(&with_cap, addr, 0, x"", x"");
    DiemAccount::restore_withdraw_capability(with_cap);

    assert(DiemAccount::balance<Coin1>(addr) == old_balance, 42);
}
}
// check: "Keep(ABORTED { code: 519,"