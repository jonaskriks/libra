
<a name="0x1_Coin1"></a>

# Module `0x1::Coin1`

This module defines the coin type Coin1 and its initialization function.


-  [Struct `Coin1`](#0x1_Coin1_Coin1)
-  [Function `initialize`](#0x1_Coin1_initialize)
-  [Module Specification](#@Module_Specification_0)
    -  [Persistence of Resources](#@Persistence_of_Resources_1)


<pre><code><b>use</b> <a href="AccountLimits.md#0x1_AccountLimits">0x1::AccountLimits</a>;
<b>use</b> <a href="Diem.md#0x1_Diem">0x1::Diem</a>;
<b>use</b> <a href="DiemTimestamp.md#0x1_DiemTimestamp">0x1::DiemTimestamp</a>;
<b>use</b> <a href="FixedPoint32.md#0x1_FixedPoint32">0x1::FixedPoint32</a>;
</code></pre>



<a name="0x1_Coin1_Coin1"></a>

## Struct `Coin1`

The type tag representing the <code><a href="Coin1.md#0x1_Coin1">Coin1</a></code> currency on-chain.


<pre><code><b>struct</b> <a href="Coin1.md#0x1_Coin1">Coin1</a>
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

<a name="0x1_Coin1_initialize"></a>

## Function `initialize`

Registers the <code><a href="Coin1.md#0x1_Coin1">Coin1</a></code> cointype. This can only be called from genesis.


<pre><code><b>public</b> <b>fun</b> <a href="Coin1.md#0x1_Coin1_initialize">initialize</a>(dr_account: &signer, tc_account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Coin1.md#0x1_Coin1_initialize">initialize</a>(
    dr_account: &signer,
    tc_account: &signer,
) {
    <a href="DiemTimestamp.md#0x1_DiemTimestamp_assert_genesis">DiemTimestamp::assert_genesis</a>();
    <a href="Diem.md#0x1_Diem_register_SCS_currency">Diem::register_SCS_currency</a>&lt;<a href="Coin1.md#0x1_Coin1">Coin1</a>&gt;(
        dr_account,
        tc_account,
        <a href="FixedPoint32.md#0x1_FixedPoint32_create_from_rational">FixedPoint32::create_from_rational</a>(1, 1), // exchange rate <b>to</b> <a href="XDM.md#0x1_XDM">XDM</a>
        1000000, // scaling_factor = 10^6
        100,     // fractional_part = 10^2
        b"<a href="Coin1.md#0x1_Coin1">Coin1</a>"
    );
    <a href="AccountLimits.md#0x1_AccountLimits_publish_unrestricted_limits">AccountLimits::publish_unrestricted_limits</a>&lt;<a href="Coin1.md#0x1_Coin1">Coin1</a>&gt;(dr_account);
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>include</b> <a href="Diem.md#0x1_Diem_RegisterSCSCurrencyAbortsIf">Diem::RegisterSCSCurrencyAbortsIf</a>&lt;<a href="Coin1.md#0x1_Coin1">Coin1</a>&gt;{
    currency_code: b"<a href="Coin1.md#0x1_Coin1">Coin1</a>",
    scaling_factor: 1000000
};
<b>include</b> <a href="AccountLimits.md#0x1_AccountLimits_PublishUnrestrictedLimitsAbortsIf">AccountLimits::PublishUnrestrictedLimitsAbortsIf</a>&lt;<a href="Coin1.md#0x1_Coin1">Coin1</a>&gt;{publish_account: dr_account};
<b>include</b> <a href="Diem.md#0x1_Diem_RegisterSCSCurrencyEnsures">Diem::RegisterSCSCurrencyEnsures</a>&lt;<a href="Coin1.md#0x1_Coin1">Coin1</a>&gt;;
<b>include</b> <a href="AccountLimits.md#0x1_AccountLimits_PublishUnrestrictedLimitsEnsures">AccountLimits::PublishUnrestrictedLimitsEnsures</a>&lt;<a href="Coin1.md#0x1_Coin1">Coin1</a>&gt;{publish_account: dr_account};
</code></pre>


Registering Coin1 can only be done in genesis.


<pre><code><b>include</b> <a href="DiemTimestamp.md#0x1_DiemTimestamp_AbortsIfNotGenesis">DiemTimestamp::AbortsIfNotGenesis</a>;
</code></pre>


Only the DiemRoot account can register a new currency [[H8]][PERMISSION].


<pre><code><b>include</b> <a href="Roles.md#0x1_Roles_AbortsIfNotDiemRoot">Roles::AbortsIfNotDiemRoot</a>{account: dr_account};
</code></pre>


Only a TreasuryCompliance account can have the MintCapability [[H1]][PERMISSION].
Moreover, only a TreasuryCompliance account can have the BurnCapability [[H3]][PERMISSION].


<pre><code><b>include</b> <a href="Roles.md#0x1_Roles_AbortsIfNotTreasuryCompliance">Roles::AbortsIfNotTreasuryCompliance</a>{account: tc_account};
</code></pre>



</details>

<a name="@Module_Specification_0"></a>

## Module Specification



<a name="@Persistence_of_Resources_1"></a>

### Persistence of Resources


After genesis, Coin1 is registered.


<pre><code><b>invariant</b> [<b>global</b>] <a href="DiemTimestamp.md#0x1_DiemTimestamp_is_operating">DiemTimestamp::is_operating</a>() ==&gt; <a href="Diem.md#0x1_Diem_is_currency">Diem::is_currency</a>&lt;<a href="Coin1.md#0x1_Coin1">Coin1</a>&gt;();
</code></pre>


After genesis, <code>LimitsDefinition&lt;<a href="Coin1.md#0x1_Coin1">Coin1</a>&gt;</code> is published at Diem root. It's published by
AccountLimits::publish_unrestricted_limits, but we can't prove the condition there because
it does not hold for all types (but does hold for Coin1).


<pre><code><b>invariant</b> [<b>global</b>] <a href="DiemTimestamp.md#0x1_DiemTimestamp_is_operating">DiemTimestamp::is_operating</a>()
    ==&gt; <b>exists</b>&lt;<a href="AccountLimits.md#0x1_AccountLimits_LimitsDefinition">AccountLimits::LimitsDefinition</a>&lt;<a href="Coin1.md#0x1_Coin1">Coin1</a>&gt;&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>());
</code></pre>


<code>LimitsDefinition&lt;<a href="Coin1.md#0x1_Coin1">Coin1</a>&gt;</code> is not published at any other address


<pre><code><b>invariant</b> [<b>global</b>] <b>forall</b> addr: address <b>where</b> <b>exists</b>&lt;<a href="AccountLimits.md#0x1_AccountLimits_LimitsDefinition">AccountLimits::LimitsDefinition</a>&lt;<a href="Coin1.md#0x1_Coin1">Coin1</a>&gt;&gt;(addr):
    addr == <a href="CoreAddresses.md#0x1_CoreAddresses_DIEM_ROOT_ADDRESS">CoreAddresses::DIEM_ROOT_ADDRESS</a>();
</code></pre>


[//]: # ("File containing references which can be used from documentation")
[ACCESS_CONTROL]: https://github.com/libra/lip/blob/master/lips/lip-2.md
[ROLE]: https://github.com/libra/lip/blob/master/lips/lip-2.md#roles
[PERMISSION]: https://github.com/libra/lip/blob/master/lips/lip-2.md#permissions
