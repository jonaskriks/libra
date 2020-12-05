//! account: bob, 100000000Coin1, 0
//! account: alice, 100000000Coin1, 0

//! new-transaction
module Holder {
    resource struct Hold<T> { x: T }
    public fun hold<T>(account: &signer, x: T) {
        move_to(account, Hold<T>{ x })
    }
}

//! new-transaction
script {
use 0x1::AccountLimits;
use {{default}}::Holder;
fun main(account: &signer) {
    Holder::hold(
        account,
        AccountLimits::grant_mutation_capability(account)
    );
}
}

//! new-transaction
//! sender: diemroot
//! execute-as: bob
script {
use 0x1::AccountLimits;
use 0x1::Coin1::Coin1;
fun main(dr: &signer, bob_account: &signer) {
    AccountLimits::publish_unrestricted_limits<Coin1>(bob_account);
    AccountLimits::publish_window<Coin1>(dr, bob_account, {{bob}});
}
}

//! new-transaction
//! sender: diemroot
//! execute-as: bob
script {
use 0x1::AccountLimits;
use 0x1::Coin1::Coin1;
fun main(dr: &signer, bob_account: &signer) {
    AccountLimits::publish_window<Coin1>(dr, bob_account, {{bob}});
}
}

//! new-transaction
//! sender: bob
script {
use 0x1::AccountLimits;
use 0x1::Coin1::Coin1;
fun main(bob_account: &signer) {
    AccountLimits::publish_window<Coin1>(bob_account, bob_account, {{bob}});
}
}

//! new-transaction
//! sender: bob
script {
use 0x1::AccountLimits;
use 0x1::Coin1::Coin1;
fun main(bob_account: &signer) {
    AccountLimits::publish_unrestricted_limits<Coin1>(bob_account);
}
}

//! new-transaction
//! sender: blessed
script {
use 0x1::AccountLimits;
use 0x1::Coin1::Coin1;
fun main(tc: &signer) {
    AccountLimits::update_limits_definition<Coin1>(
        tc,
        {{bob}},
        100, /* new_max_inflow */
        200, /* new_max_outflow */
        150, /* new_max_holding_balance */
        10000, /* new_time_period */
    )
}
}

//! new-transaction
//! sender: diemroot
script {
use 0x1::AccountLimits;
use 0x1::Coin1::Coin1;
fun main(tc: &signer) {
    AccountLimits::update_limits_definition<Coin1>(
        tc,
        {{bob}},
        100, /* new_max_inflow */
        200, /* new_max_outflow */
        150, /* new_max_holding_balance */
        10000, /* new_time_period */
    )
}
}

//! new-transaction
//! sender: blessed
script {
use 0x1::AccountLimits;
use 0x1::Coin1::Coin1;
fun main(tc: &signer) {
    AccountLimits::update_limits_definition<Coin1>(
        tc,
        {{bob}},
        0, /* new_max_inflow */
        0, /* new_max_outflow */
        150, /* new_max_holding_balance */
        10000, /* new_time_period */
    )
}
}

//! new-transaction
//! sender: blessed
script {
use 0x1::AccountLimits;
use 0x1::Coin1::Coin1;
fun main(tc: &signer) {
    AccountLimits::update_limits_definition<Coin1>(
        tc,
        {{default}},
        0, /* new_max_inflow */
        0, /* new_max_outflow */
        150, /* new_max_holding_balance */
        10000, /* new_time_period */
    )
}
}

//! new-transaction
//! sender: blessed
script {
use 0x1::AccountLimits;
use 0x1::Coin1::Coin1;
fun main(tc: &signer) {
    AccountLimits::update_limits_definition<Coin1>(
        tc,
        {{bob}},
        0, /* new_max_inflow */
        0, /* new_max_outflow */
        150, /* new_max_holding_balance */
        10000, /* new_time_period */
    )
}
}

//! new-transaction
//! sender: blessed
script {
use 0x1::AccountLimits;
use 0x1::Coin1::Coin1;
fun main(tc: &signer) {
    AccountLimits::update_window_info<Coin1>(
        tc,
        {{bob}},
        120,
        {{bob}},
    )
}
}

//! new-transaction
//! sender: blessed
script {
use 0x1::AccountLimits;
use 0x1::Coin1::Coin1;
fun main(tc: &signer) {
    AccountLimits::update_window_info<Coin1>(
        tc,
        {{bob}},
        0,
        {{bob}},
    )
}
}

//! new-transaction
//! sender: blessed
script {
use 0x1::AccountLimits;
use 0x1::Coin1::Coin1;
fun main(tc: &signer) {
    AccountLimits::update_window_info<Coin1>(
        tc,
        {{bob}},
        120,
        {{alice}},
    )
}
}

//! new-transaction
//! sender: diemroot
script {
use 0x1::AccountLimits;
use 0x1::Coin1::Coin1;
fun main(dr: &signer) {
    AccountLimits::update_window_info<Coin1>(
        dr,
        {{bob}},
        120,
        {{bob}},
    )
}
}

//! new-transaction
//! sender: blessed
script {
use 0x1::AccountLimits;
use 0x1::Coin1::Coin1;
fun main() {
    assert(AccountLimits::limits_definition_address<Coin1>({{bob}}) == {{bob}}, 0);
}
}

//! new-transaction
//! sender: blessed
script {
use 0x1::AccountLimits;
use 0x1::Coin1::Coin1;
fun main() {
    assert(AccountLimits::has_limits_published<Coin1>({{bob}}), 1);

    assert(!AccountLimits::has_limits_published<Coin1>({{alice}}), 3);
}
}

//! new-transaction
//! sender: diemroot
//! execute-as: bob
script {
use 0x1::AccountLimits;
use 0x1::Coin1::Coin1;
fun main(dr: &signer, bob_account: &signer) {
    AccountLimits::publish_window<Coin1>(dr, bob_account, {{default}});
}
}