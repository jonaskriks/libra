//! new-transaction
//! sender: blessed
script {
use 0x1::Diem;
use 0x1::Coin1::Coin1;
use 0x1::FixedPoint32;
fun main(account: &signer) {
    assert(Diem::approx_xdm_for_value<Coin1>(10) == 10, 1);
    assert(Diem::scaling_factor<Coin1>() == 1000000, 2);
    assert(Diem::fractional_part<Coin1>() == 100, 3);
    Diem::update_xdm_exchange_rate<Coin1>(account, FixedPoint32::create_from_rational(1, 3));
    assert(Diem::approx_xdm_for_value<Coin1>(10) == 3, 4);
}
}
// check: ToXDMExchangeRateUpdateEvent
// check: "Keep(EXECUTED)"
