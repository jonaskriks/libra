address 0x1 {

/// This module defines the coin type Coin1 and its initialization function.
module Coin1 {
    use 0x1::AccountLimits;
    use 0x1::Diem;
    use 0x1::DiemTimestamp;
    use 0x1::FixedPoint32;

    /// The type tag representing the `Coin1` currency on-chain.
    struct Coin1 { }

    /// Registers the `Coin1` cointype. This can only be called from genesis.
    public fun initialize(
        dr_account: &signer,
        tc_account: &signer,
    ) {
        DiemTimestamp::assert_genesis();
        Diem::register_SCS_currency<Coin1>(
            dr_account,
            tc_account,
            FixedPoint32::create_from_rational(1, 1), // exchange rate to XDM
            1000000, // scaling_factor = 10^6
            100,     // fractional_part = 10^2
            b"Coin1"
        );
        AccountLimits::publish_unrestricted_limits<Coin1>(dr_account);
    }
    spec fun initialize {
        use 0x1::Roles;
        include Diem::RegisterSCSCurrencyAbortsIf<Coin1>{
            currency_code: b"Coin1",
            scaling_factor: 1000000
        };
        include AccountLimits::PublishUnrestrictedLimitsAbortsIf<Coin1>{publish_account: dr_account};
        include Diem::RegisterSCSCurrencyEnsures<Coin1>;
        include AccountLimits::PublishUnrestrictedLimitsEnsures<Coin1>{publish_account: dr_account};
        /// Registering Coin1 can only be done in genesis.
        include DiemTimestamp::AbortsIfNotGenesis;
        /// Only the DiemRoot account can register a new currency [[H8]][PERMISSION].
        include Roles::AbortsIfNotDiemRoot{account: dr_account};
        /// Only a TreasuryCompliance account can have the MintCapability [[H1]][PERMISSION].
        /// Moreover, only a TreasuryCompliance account can have the BurnCapability [[H3]][PERMISSION].
        include Roles::AbortsIfNotTreasuryCompliance{account: tc_account};
    }

    // =================================================================
    // Module Specification

    spec module {} // Switch to module documentation context

    /// # Persistence of Resources
    spec module {
        use 0x1::CoreAddresses;

        /// After genesis, Coin1 is registered.
        invariant [global] DiemTimestamp::is_operating() ==> Diem::is_currency<Coin1>();

        /// After genesis, `LimitsDefinition<Coin1>` is published at Diem root. It's published by
        /// AccountLimits::publish_unrestricted_limits, but we can't prove the condition there because
        /// it does not hold for all types (but does hold for Coin1).
        invariant [global] DiemTimestamp::is_operating()
            ==> exists<AccountLimits::LimitsDefinition<Coin1>>(CoreAddresses::DIEM_ROOT_ADDRESS());

        /// `LimitsDefinition<Coin1>` is not published at any other address
        invariant [global] forall addr: address where exists<AccountLimits::LimitsDefinition<Coin1>>(addr):
            addr == CoreAddresses::DIEM_ROOT_ADDRESS();

    }
}
}
