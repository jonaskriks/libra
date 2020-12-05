
<a name="0x1_XDM"></a>

# Module `0x1::XDM`

NB: This module is a stub of the <code><a href="XDM.md#0x1_XDM">XDM</a></code> at the moment.

Once the component makeup of the XDM has been chosen the
<code><a href="XDM.md#0x1_XDM_Reserve">Reserve</a></code> will be updated to hold the backing coins in the correct ratios.


-  [Resource `XDM`](#0x1_XDM_XDM)
-  [Resource `Reserve`](#0x1_XDM_Reserve)
-  [Constants](#@Constants_0)
-  [Function `initialize`](#0x1_XDM_initialize)
-  [Function `is_xdm`](#0x1_XDM_is_xdm)
-  [Function `reserve_address`](#0x1_XDM_reserve_address)
-  [Module Specification](#@Module_Specification_1)
    -  [Persistence of Resources](#@Persistence_of_Resources_2)
    -  [Helper Functions](#@Helper_Functions_3)


<pre><code><b>use</b> <a href="AccountLimits.md#0x1_AccountLimits">0x1::AccountLimits</a>;
<b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="Diem.md#0x1_Diem">0x1::Diem</a>;
<b>use</b> <a href="DiemTimestamp.md#0x1_DiemTimestamp">0x1::DiemTimestamp</a>;
<b>use</b> <a href="Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="FixedPoint32.md#0x1_FixedPoint32">0x1::FixedPoint32</a>;
</code></pre>



<a name="0x1_XDM_XDM"></a>

## Resource `XDM`

The type tag representing the <code><a href="XDM.md#0x1_XDM">XDM</a></code> currency on-chain.


<pre><code><b>resource</b> <b>struct</b> <a href="XDM.md#0x1_XDM">XDM</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>dummy_field: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_XDM_Reserve"></a>

## Resource `Reserve`

Note: Currently only holds the mint, burn, and preburn capabilities for
XDM. Once the makeup of the XDM has been determined this resource will
be updated to hold the backing XDM reserve compnents on-chain.

The on-chain reserve for the <code><a href="XDM.md#0x1_XDM">XDM</a></code> holds both the capability for minting <code><a href="XDM.md#0x1_XDM">XDM</a></code>
coins, and also each reserve component that holds the backing for these coins on-chain.
Currently this holds no coins since XDM is not able to be minted/created.


<pre><code><b>resource</b> <b>struct</b> <a href="XDM.md#0x1_XDM_Reserve">Reserve</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>mint_cap: <a href="Diem.md#0x1_Diem_MintCapability">Diem::MintCapability</a>&lt;<a href="XDM.md#0x1_XDM_XDM">XDM::XDM</a>&gt;</code>
</dt>
<dd>
 The mint capability allowing minting of <code><a href="XDM.md#0x1_XDM">XDM</a></code> coins.
</dd>
<dt>
<code>burn_cap: <a href="Diem.md#0x1_Diem_BurnCapability">Diem::BurnCapability</a>&lt;<a href="XDM.md#0x1_XDM_XDM">XDM::XDM</a>&gt;</code>
</dt>
<dd>
 The burn capability for <code><a href="XDM.md#0x1_XDM">XDM</a></code> coins. This is used for the unpacking
 of <code><a href="XDM.md#0x1_XDM">XDM</a></code> coins into the underlying backing currencies.
</dd>
<dt>
<code>preburn_cap: <a href="Diem.md#0x1_Diem_Preburn">Diem::Preburn</a>&lt;<a href="XDM.md#0x1_XDM_XDM">XDM::XDM</a>&gt;</code>
</dt>
<dd>
 The preburn for <code><a href="XDM.md#0x1_XDM">XDM</a></code>. This is an administrative field since we
 need to alway preburn before we burn.
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1_XDM_ERESERVE"></a>

The <code><a href="XDM.md#0x1_XDM_Reserve">Reserve</a></code> resource is in an invalid state


<pre><code><b>const</b> <a href="XDM.md#0x1_XDM_ERESERVE">ERESERVE</a>: u64 = 0;
</code></pre>



<a name="0x1_XDM_initialize"></a>

## Function `initialize`

Initializes the <code><a href="XDM.md#0x1_XDM">XDM</a></code> module. This sets up the initial <code><a href="XDM.md#0x1_XDM">XDM</a></code> ratios and
reserve components, and creates the mint, preburn, and burn
capabilities for <code><a href="XDM.md#0x1_XDM">XDM</a></code> coins. The <code><a href="XDM.md#0x1_XDM">XDM</a></code> currency must not already be
registered in order for this to succeed. The sender must both be the
correct address (<code><a href="CoreAddresses.md#0x1_CoreAddresses_CURRENCY_INFO_ADDRESS">CoreAddresses::CURRENCY_INFO_ADDRESS</a></code>) and have the
correct permissions (<code>&Capability&lt;RegisterNewCurrency&gt;</code>). Both of these
restrictions are enforced in the <code><a href="Diem.md#0x1_Diem_register_currency">Diem::register_currency</a></code> function, but also enforced here.


<pre><code><b>public</b> <b>fun</b> <a href="XDM.md#0x1_XDM_initialize">initialize</a>(dr_account: &signer, tc_account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="XDM.md#0x1_XDM_initialize">initialize</a>(
    dr_account: &signer,
    tc_account: &signer,
) {
    <a href="DiemTimestamp.md#0x1_DiemTimestamp_assert_genesis">DiemTimestamp::assert_genesis</a>();
    // Operational constraint
    <a href="CoreAddresses.md#0x1_CoreAddresses_assert_currency_info">CoreAddresses::assert_currency_info</a>(dr_account);
    // <a href="XDM.md#0x1_XDM_Reserve">Reserve</a> must not exist.
    <b>assert</b>(!<b>exists</b>&lt;<a href="XDM.md#0x1_XDM_Reserve">Reserve</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>()), <a href="Errors.md#0x1_Errors_already_published">Errors::already_published</a>(<a href="XDM.md#0x1_XDM_ERESERVE">ERESERVE</a>));
    <b>let</b> (mint_cap, burn_cap) = <a href="Diem.md#0x1_Diem_register_currency">Diem::register_currency</a>&lt;<a href="XDM.md#0x1_XDM">XDM</a>&gt;(
        dr_account,
        <a href="FixedPoint32.md#0x1_FixedPoint32_create_from_rational">FixedPoint32::create_from_rational</a>(1, 1), // exchange rate <b>to</b> <a href="XDM.md#0x1_XDM">XDM</a>
        <b>true</b>,    // is_synthetic
        1000000, // scaling_factor = 10^6
        1000,    // fractional_part = 10^3
        b"<a href="XDM.md#0x1_XDM">XDM</a>"
    );
    // <a href="XDM.md#0x1_XDM">XDM</a> cannot be minted.
    <a href="Diem.md#0x1_Diem_update_minting_ability">Diem::update_minting_ability</a>&lt;<a href="XDM.md#0x1_XDM">XDM</a>&gt;(tc_account, <b>false</b>);
    <a href="AccountLimits.md#0x1_AccountLimits_publish_unrestricted_limits">AccountLimits::publish_unrestricted_limits</a>&lt;<a href="XDM.md#0x1_XDM">XDM</a>&gt;(dr_account);
    <b>let</b> preburn_cap = <a href="Diem.md#0x1_Diem_create_preburn">Diem::create_preburn</a>&lt;<a href="XDM.md#0x1_XDM">XDM</a>&gt;(tc_account);
    move_to(dr_account, <a href="XDM.md#0x1_XDM_Reserve">Reserve</a> { mint_cap, burn_cap, preburn_cap });
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>include</b> <a href="CoreAddresses.md#0x1_CoreAddresses_AbortsIfNotCurrencyInfo">CoreAddresses::AbortsIfNotCurrencyInfo</a>{account: dr_account};
<b>aborts_if</b> <b>exists</b>&lt;<a href="XDM.md#0x1_XDM_Reserve">Reserve</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>()) <b>with</b> <a href="Errors.md#0x1_Errors_ALREADY_PUBLISHED">Errors::ALREADY_PUBLISHED</a>;
<b>include</b> <a href="Diem.md#0x1_Diem_RegisterCurrencyAbortsIf">Diem::RegisterCurrencyAbortsIf</a>&lt;<a href="XDM.md#0x1_XDM">XDM</a>&gt;{
    currency_code: b"<a href="XDM.md#0x1_XDM">XDM</a>",
    scaling_factor: 1000000
};
<b>include</b> <a href="AccountLimits.md#0x1_AccountLimits_PublishUnrestrictedLimitsAbortsIf">AccountLimits::PublishUnrestrictedLimitsAbortsIf</a>&lt;<a href="XDM.md#0x1_XDM">XDM</a>&gt;{publish_account: dr_account};
<b>include</b> <a href="Diem.md#0x1_Diem_RegisterCurrencyEnsures">Diem::RegisterCurrencyEnsures</a>&lt;<a href="XDM.md#0x1_XDM">XDM</a>&gt;;
<b>include</b> <a href="Diem.md#0x1_Diem_UpdateMintingAbilityEnsures">Diem::UpdateMintingAbilityEnsures</a>&lt;<a href="XDM.md#0x1_XDM">XDM</a>&gt;{can_mint: <b>false</b>};
<b>include</b> <a href="AccountLimits.md#0x1_AccountLimits_PublishUnrestrictedLimitsEnsures">AccountLimits::PublishUnrestrictedLimitsEnsures</a>&lt;<a href="XDM.md#0x1_XDM">XDM</a>&gt;{publish_account: dr_account};
<b>ensures</b> <b>exists</b>&lt;<a href="XDM.md#0x1_XDM_Reserve">Reserve</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>());
</code></pre>


Registering XDM can only be done in genesis.


<pre><code><b>include</b> <a href="DiemTimestamp.md#0x1_DiemTimestamp_AbortsIfNotGenesis">DiemTimestamp::AbortsIfNotGenesis</a>;
</code></pre>


Only the DiemRoot account can register a new currency [[H8]][PERMISSION].


<pre><code><b>include</b> <a href="Roles.md#0x1_Roles_AbortsIfNotDiemRoot">Roles::AbortsIfNotDiemRoot</a>{account: dr_account};
</code></pre>


Only the TreasuryCompliance role can update the <code>can_mint</code> field of CurrencyInfo [[H2]][PERMISSION].
Moreover, only the TreasuryCompliance role can create Preburn.


<pre><code><b>include</b> <a href="Roles.md#0x1_Roles_AbortsIfNotTreasuryCompliance">Roles::AbortsIfNotTreasuryCompliance</a>{account: tc_account};
</code></pre>



</details>

<a name="0x1_XDM_is_xdm"></a>

## Function `is_xdm`

Returns true if <code>CoinType</code> is <code><a href="XDM.md#0x1_XDM_XDM">XDM::XDM</a></code>


<pre><code><b>public</b> <b>fun</b> <a href="XDM.md#0x1_XDM_is_xdm">is_xdm</a>&lt;CoinType&gt;(): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="XDM.md#0x1_XDM_is_xdm">is_xdm</a>&lt;CoinType&gt;(): bool {
    <a href="Diem.md#0x1_Diem_is_currency">Diem::is_currency</a>&lt;CoinType&gt;() &&
        <a href="Diem.md#0x1_Diem_currency_code">Diem::currency_code</a>&lt;CoinType&gt;() == <a href="Diem.md#0x1_Diem_currency_code">Diem::currency_code</a>&lt;<a href="XDM.md#0x1_XDM">XDM</a>&gt;()
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>pragma</b> opaque, verify = <b>false</b>;
<b>include</b> <a href="Diem.md#0x1_Diem_spec_is_currency">Diem::spec_is_currency</a>&lt;CoinType&gt;() ==&gt; <a href="Diem.md#0x1_Diem_AbortsIfNoCurrency">Diem::AbortsIfNoCurrency</a>&lt;<a href="XDM.md#0x1_XDM">XDM</a>&gt;;
</code></pre>


The following is correct because currency codes are unique; however, we
can currently not prove it, therefore verify is false.


<pre><code><b>ensures</b> result == <a href="Diem.md#0x1_Diem_spec_is_currency">Diem::spec_is_currency</a>&lt;CoinType&gt;() && <a href="XDM.md#0x1_XDM_spec_is_xdm">spec_is_xdm</a>&lt;CoinType&gt;();
</code></pre>



</details>

<a name="0x1_XDM_reserve_address"></a>

## Function `reserve_address`

Return the account address where the globally unique XDM::Reserve resource is stored


<pre><code><b>public</b> <b>fun</b> <a href="XDM.md#0x1_XDM_reserve_address">reserve_address</a>(): address
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="XDM.md#0x1_XDM_reserve_address">reserve_address</a>(): address {
    <a href="CoreAddresses.md#0x1_CoreAddresses_CURRENCY_INFO_ADDRESS">CoreAddresses::CURRENCY_INFO_ADDRESS</a>()
}
</code></pre>



</details>

<a name="@Module_Specification_1"></a>

## Module Specification



<a name="@Persistence_of_Resources_2"></a>

### Persistence of Resources


After genesis, the Reserve resource exists.


<pre><code><b>invariant</b> [<b>global</b>] <a href="DiemTimestamp.md#0x1_DiemTimestamp_is_operating">DiemTimestamp::is_operating</a>() ==&gt; <a href="XDM.md#0x1_XDM_reserve_exists">reserve_exists</a>();
</code></pre>


After genesis, XDM is registered.


<pre><code><b>invariant</b> [<b>global</b>] <a href="DiemTimestamp.md#0x1_DiemTimestamp_is_operating">DiemTimestamp::is_operating</a>() ==&gt; <a href="Diem.md#0x1_Diem_is_currency">Diem::is_currency</a>&lt;<a href="XDM.md#0x1_XDM">XDM</a>&gt;();
</code></pre>



<a name="@Helper_Functions_3"></a>

### Helper Functions


Checks whether the Reserve resource exists.


<a name="0x1_XDM_reserve_exists"></a>


<pre><code><b>define</b> <a href="XDM.md#0x1_XDM_reserve_exists">reserve_exists</a>(): bool {
   <b>exists</b>&lt;<a href="XDM.md#0x1_XDM_Reserve">Reserve</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_CURRENCY_INFO_ADDRESS">CoreAddresses::CURRENCY_INFO_ADDRESS</a>())
}
</code></pre>


Returns true if CoinType is XDM.


<a name="0x1_XDM_spec_is_xdm"></a>


<pre><code><b>define</b> <a href="XDM.md#0x1_XDM_spec_is_xdm">spec_is_xdm</a>&lt;CoinType&gt;(): bool {
    type&lt;CoinType&gt;() == type&lt;<a href="XDM.md#0x1_XDM">XDM</a>&gt;()
}
</code></pre>


After genesis, <code>LimitsDefinition&lt;<a href="XDM.md#0x1_XDM">XDM</a>&gt;</code> is published at Diem root. It's published by
AccountLimits::publish_unrestricted_limits, but we can't prove the condition there because
it does not hold for all types (but does hold for XDM).


<pre><code><b>invariant</b> [<b>global</b>] <a href="DiemTimestamp.md#0x1_DiemTimestamp_is_operating">DiemTimestamp::is_operating</a>()
    ==&gt; <b>exists</b>&lt;<a href="AccountLimits.md#0x1_AccountLimits_LimitsDefinition">AccountLimits::LimitsDefinition</a>&lt;<a href="XDM.md#0x1_XDM">XDM</a>&gt;&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>());
</code></pre>


<code>LimitsDefinition&lt;<a href="XDM.md#0x1_XDM">XDM</a>&gt;</code> is not published at any other address


<pre><code><b>invariant</b> [<b>global</b>] <b>forall</b> addr: address <b>where</b> <b>exists</b>&lt;<a href="AccountLimits.md#0x1_AccountLimits_LimitsDefinition">AccountLimits::LimitsDefinition</a>&lt;<a href="XDM.md#0x1_XDM">XDM</a>&gt;&gt;(addr):
    addr == <a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>();
</code></pre>


<code><a href="XDM.md#0x1_XDM_Reserve">Reserve</a></code> is persistent


<pre><code><b>invariant</b> <b>update</b> [<b>global</b>] <b>old</b>(<b>exists</b>&lt;<a href="XDM.md#0x1_XDM_Reserve">Reserve</a>&gt;(<a href="XDM.md#0x1_XDM_reserve_address">reserve_address</a>()))
    ==&gt; <b>exists</b>&lt;<a href="XDM.md#0x1_XDM_Reserve">Reserve</a>&gt;(<a href="XDM.md#0x1_XDM_reserve_address">reserve_address</a>());
</code></pre>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/libra/lip/blob/master/lips/lip-2.md
[ROLE]: https://github.com/libra/lip/blob/master/lips/lip-2.md#roles
[PERMISSION]: https://github.com/libra/lip/blob/master/lips/lip-2.md#permissions