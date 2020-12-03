address 0x1 {
/// NB: This module is a stub of the `XDM` at the moment.
///
/// Once the component makeup of the XDM has been chosen the
/// `Reserve` will be updated to hold the backing coins in the correct ratios.

module XDM {
    use 0x1::AccountLimits;
    use 0x1::CoreAddresses;
    use 0x1::Errors;
    use 0x1::FixedPoint32;
    use 0x1::Diem;
    use 0x1::DiemTimestamp;

    /// The type tag representing the `XDM` currency on-chain.
    resource struct XDM { }

    /// Note: Currently only holds the mint, burn, and preburn capabilities for
    /// XDM. Once the makeup of the XDM has been determined this resource will
    /// be updated to hold the backing XDM reserve compnents on-chain.
    ///
    /// The on-chain reserve for the `XDM` holds both the capability for minting `XDM`
    /// coins, and also each reserve component that holds the backing for these coins on-chain.
    /// Currently this holds no coins since XDM is not able to be minted/created.
    resource struct Reserve {
        /// The mint capability allowing minting of `XDM` coins.
        mint_cap: Diem::MintCapability<XDM>,
        /// The burn capability for `XDM` coins. This is used for the unpacking
        /// of `XDM` coins into the underlying backing currencies.
        burn_cap: Diem::BurnCapability<XDM>,
        /// The preburn for `XDM`. This is an administrative field since we
        /// need to alway preburn before we burn.
        preburn_cap: Diem::Preburn<XDM>,
        // TODO: Once the reserve has been determined this resource will
        // contain a ReserveComponent<Currency> for every currency that makes
        // up the reserve.
    }

    /// The `Reserve` resource is in an invalid state
    const ERESERVE: u64 = 0;

    /// Initializes the `XDM` module. This sets up the initial `XDM` ratios and
    /// reserve components, and creates the mint, preburn, and burn
    /// capabilities for `XDM` coins. The `XDM` currency must not already be
    /// registered in order for this to succeed. The sender must both be the
    /// correct address (`CoreAddresses::CURRENCY_INFO_ADDRESS`) and have the
    /// correct permissions (`&Capability<RegisterNewCurrency>`). Both of these
    /// restrictions are enforced in the `Diem::register_currency` function, but also enforced here.
    public fun initialize(
        dr_account: &signer,
        tc_account: &signer,
    ) {
        DiemTimestamp::assert_genesis();
        // Operational constraint
        CoreAddresses::assert_currency_info(dr_account);
        // Reserve must not exist.
        assert(!exists<Reserve>(CoreAddresses::DIEM_ROOT_ADDRESS()), Errors::already_published(ERESERVE));
        let (mint_cap, burn_cap) = Diem::register_currency<XDM>(
            dr_account,
            FixedPoint32::create_from_rational(1, 1), // exchange rate to XDM
            true,    // is_synthetic
            1000000, // scaling_factor = 10^6
            1000,    // fractional_part = 10^3
            b"XDM"
        );
        // XDM cannot be minted.
        Diem::update_minting_ability<XDM>(tc_account, false);
        AccountLimits::publish_unrestricted_limits<XDM>(dr_account);
        let preburn_cap = Diem::create_preburn<XDM>(tc_account);
        move_to(dr_account, Reserve { mint_cap, burn_cap, preburn_cap });
    }
    spec fun initialize {
       use 0x1::Roles;
        include CoreAddresses::AbortsIfNotCurrencyInfo{account: dr_account};
        aborts_if exists<Reserve>(CoreAddresses::DIEM_ROOT_ADDRESS()) with Errors::ALREADY_PUBLISHED;
        include Diem::RegisterCurrencyAbortsIf<XDM>{
            currency_code: b"XDM",
            scaling_factor: 1000000
        };
        include AccountLimits::PublishUnrestrictedLimitsAbortsIf<XDM>{publish_account: dr_account};

        include Diem::RegisterCurrencyEnsures<XDM>;
        include Diem::UpdateMintingAbilityEnsures<XDM>{can_mint: false};
        include AccountLimits::PublishUnrestrictedLimitsEnsures<XDM>{publish_account: dr_account};
        ensures exists<Reserve>(CoreAddresses::DIEM_ROOT_ADDRESS());

        /// Registering XDM can only be done in genesis.
        include DiemTimestamp::AbortsIfNotGenesis;
        /// Only the DiemRoot account can register a new currency [[H8]][PERMISSION].
        include Roles::AbortsIfNotDiemRoot{account: dr_account};
        /// Only the TreasuryCompliance role can update the `can_mint` field of CurrencyInfo [[H2]][PERMISSION].
        /// Moreover, only the TreasuryCompliance role can create Preburn.
        include Roles::AbortsIfNotTreasuryCompliance{account: tc_account};
    }

    /// Returns true if `CoinType` is `XDM::XDM`
    public fun is_xdm<CoinType>(): bool {
        Diem::is_currency<CoinType>() &&
            Diem::currency_code<CoinType>() == Diem::currency_code<XDM>()
    }

    spec fun is_xdm {
        pragma opaque, verify = false;
        include Diem::spec_is_currency<CoinType>() ==> Diem::AbortsIfNoCurrency<XDM>;
        /// The following is correct because currency codes are unique; however, we
        /// can currently not prove it, therefore verify is false.
        ensures result == Diem::spec_is_currency<CoinType>() && spec_is_xdm<CoinType>();
    }

    /// Return the account address where the globally unique XDM::Reserve resource is stored
    public fun reserve_address(): address {
        CoreAddresses::CURRENCY_INFO_ADDRESS()
    }

    // =================================================================
    // Module Specification

    spec module {} // switch documentation context back to module level

    /// # Persistence of Resources

    spec module {
        /// After genesis, the Reserve resource exists.
        invariant [global] DiemTimestamp::is_operating() ==> reserve_exists();

        /// After genesis, XDM is registered.
        invariant [global] DiemTimestamp::is_operating() ==> Diem::is_currency<XDM>();
    }

    /// # Helper Functions
    spec module {
        /// Checks whether the Reserve resource exists.
        define reserve_exists(): bool {
           exists<Reserve>(CoreAddresses::CURRENCY_INFO_ADDRESS())
        }

        /// Returns true if CoinType is XDM.
        define spec_is_xdm<CoinType>(): bool {
            type<CoinType>() == type<XDM>()
        }

        /// After genesis, `LimitsDefinition<XDM>` is published at Diem root. It's published by
        /// AccountLimits::publish_unrestricted_limits, but we can't prove the condition there because
        /// it does not hold for all types (but does hold for XDM).
        invariant [global] DiemTimestamp::is_operating()
            ==> exists<AccountLimits::LimitsDefinition<XDM>>(CoreAddresses::DIEM_ROOT_ADDRESS());

        /// `LimitsDefinition<XDM>` is not published at any other address
        invariant [global] forall addr: address where exists<AccountLimits::LimitsDefinition<XDM>>(addr):
            addr == CoreAddresses::DIEM_ROOT_ADDRESS();

        /// `Reserve` is persistent
        invariant update [global] old(exists<Reserve>(reserve_address()))
            ==> exists<Reserve>(reserve_address());
    }

}
}
