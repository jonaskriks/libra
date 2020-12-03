//! account: bob, 0Coin1

module Holder {
    resource struct Holder<T> { x: T }
    public fun hold<T>(account: &signer, x: T)  {
        move_to(account, Holder<T> { x })
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: blessed
script {
use 0x1::Diem;
use 0x1::Coin1::Coin1;
use {{default}}::Holder;
fun main(account: &signer) {
    let coin1_tmp = Diem::mint<Coin1>(account, 10000);
    assert(Diem::value<Coin1>(&coin1_tmp) == 10000, 0);

    let (coin1_tmp1, coin1_tmp2) = Diem::split(coin1_tmp, 5000);
    assert(Diem::value<Coin1>(&coin1_tmp1) == 5000 , 0);
    assert(Diem::value<Coin1>(&coin1_tmp2) == 5000 , 2);
    let tmp = Diem::withdraw(&mut coin1_tmp1, 1000);
    assert(Diem::value<Coin1>(&coin1_tmp1) == 4000 , 4);
    assert(Diem::value<Coin1>(&tmp) == 1000 , 5);
    Diem::deposit(&mut coin1_tmp1, tmp);
    assert(Diem::value<Coin1>(&coin1_tmp1) == 5000 , 6);
    let coin1_tmp = Diem::join(coin1_tmp1, coin1_tmp2);
    assert(Diem::value<Coin1>(&coin1_tmp) == 10000, 7);
    Holder::hold(account, coin1_tmp);

    Diem::destroy_zero(Diem::zero<Coin1>());
}
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: blessed
script {
use 0x1::Diem;
use 0x1::Coin1::Coin1;
fun main(account: &signer) {
    Diem::destroy_zero(Diem::mint<Coin1>(account, 1));
}
}
// check: "Keep(ABORTED { code: 2055,"

//! new-transaction
//! sender: bob
//! gas-currency: Coin1
script {
    use 0x1::Diem;
    use 0x1::Coin1::Coin1;
    fun main()  {
        let coins = Diem::zero<Coin1>();
        Diem::approx_xdm_for_coin<Coin1>(&coins);
        Diem::destroy_zero(coins);
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
script {
    use 0x1::Diem;
    fun main()  {
        Diem::destroy_zero(
            Diem::zero<u64>()
        );
    }
}
// check: "Keep(ABORTED { code: 261"

//! new-transaction
script {
    use 0x1::Diem;
    use 0x1::XDM::XDM;
    use 0x1::Coin1::Coin1;
    fun main()  {
        assert(!Diem::is_synthetic_currency<Coin1>(), 9);
        assert(Diem::is_synthetic_currency<XDM>(), 10);
        assert(!Diem::is_synthetic_currency<u64>(), 11);
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: blessed
script {
    use 0x1::Diem;
    use 0x1::Coin1::Coin1;
    use {{default}}::Holder;
    fun main(account: &signer)  {
        Holder::hold(
            account,
            Diem::remove_burn_capability<Coin1>(account)
        );
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: diemroot
script {
use 0x1::Diem;
use 0x1::FixedPoint32;
use {{default}}::Holder;
fun main(account: &signer) {
    let (mint_cap, burn_cap) = Diem::register_currency<u64>(
        account, FixedPoint32::create_from_rational(1, 1), true, 10, 10, b"wat"
    );
    Diem::publish_burn_capability(account, burn_cap);
    Holder::hold(account, mint_cap);
}
}
// check: "Keep(ABORTED { code: 258,"

//! new-transaction
//! sender: blessed
script {
use 0x1::Diem;
use 0x1::FixedPoint32;
use {{default}}::Holder;
fun main(account: &signer) {
    let (mint_cap, burn_cap) = Diem::register_currency<u64>(
        account, FixedPoint32::create_from_rational(1, 1), true, 10, 10, b"wat"
    );
    Holder::hold(account, mint_cap);
    Holder::hold(account, burn_cap);
}
}
// check: "Keep(ABORTED { code: 2,"

//! new-transaction
//! sender: diemroot
script {
use 0x1::Diem;
use 0x1::FixedPoint32;
fun main(account: &signer) {
    Diem::register_SCS_currency<u64>(
        account, account, FixedPoint32::create_from_rational(1, 1), 10, 10, b"wat"
    );
}
}
// check: "Keep(ABORTED { code: 258,"

//! new-transaction
//! sender: diemroot
script {
use 0x1::Diem;
use 0x1::Coin1::Coin1;
use {{default}}::Holder;
fun main(account: &signer) {
    Holder::hold(account, Diem::create_preburn<Coin1>(account));
}
}
// check: "Keep(ABORTED { code: 258,")

//! new-transaction
//! sender: diemroot
script {
use 0x1::Diem;
use 0x1::XDM::XDM;
fun main(account: &signer) {
    Diem::publish_preburn_to_account<XDM>(account, account);
}
}
// check: "Keep(ABORTED { code: 1539,")

//! new-transaction
//! sender: diemroot
script {
use 0x1::Diem;
use 0x1::Coin1::Coin1;
fun main(account: &signer) {
    Diem::publish_preburn_to_account<Coin1>(account, account);
}
}
// check: "Keep(ABORTED { code: 1539,")

//! new-transaction
//! sender: blessed
script {
use 0x1::Diem;
use 0x1::Coin1::Coin1;
fun main(account: &signer) {
    let coin1_tmp = Diem::mint<Coin1>(account, 1);
    let tmp = Diem::withdraw(&mut coin1_tmp, 10);
    Diem::destroy_zero(tmp);
    Diem::destroy_zero(coin1_tmp);
}
}
// check: "Keep(ABORTED { code: 2568,"

//! new-transaction
script {
use 0x1::Diem;
use 0x1::Coin1::Coin1;
use 0x1::XDM::XDM;
fun main() {
    assert(Diem::is_SCS_currency<Coin1>(), 99);
    assert(!Diem::is_SCS_currency<XDM>(), 98);
    assert(!Diem::is_synthetic_currency<Coin1>(), 97);
    assert(Diem::is_synthetic_currency<XDM>(), 96);
}
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: blessed
script {
use 0x1::CoreAddresses;
fun main(account: &signer) {
    CoreAddresses::assert_currency_info(account)
}
}
// check: "Keep(ABORTED { code: 770,"

//! new-transaction
//! sender: blessed
script {
use 0x1::Diem;
use 0x1::Coin1::Coin1;
fun main(tc_account: &signer) {
    let max_u64 = 18446744073709551615;
    let coin1 = Diem::mint<Coin1>(tc_account, max_u64);
    let coin2 = Diem::mint<Coin1>(tc_account, 1);
    Diem::deposit(&mut coin1, coin2);
    Diem::destroy_zero(coin1);
}
}
// check: "Keep(ABORTED { code: 1800,"
