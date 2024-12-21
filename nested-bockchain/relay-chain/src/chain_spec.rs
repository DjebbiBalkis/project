// SPDX-License-Identifier: MIT
use sp_core::crypto::UncheckedInto;
use node_template_runtime::{
    GenesisConfig, BalancesConfig, ParachainInfoConfig, WASM_BINARY,
};

pub fn development_config() -> Result<ChainSpec, String> {
    let wasm_binary = WASM_BINARY.ok_or("Wasm binary not available")?;
    Ok(ChainSpec::from_genesis(
        "Development",
        "dev",
        ChainType::Development,
        move || {
            testnet_genesis(
                wasm_binary,
                vec![authority_keys_from_seed("Alice")],
                get_account_id_from_seed::<sr25519::Public>("Alice"),
                vec![
                    get_account_id_from_seed::<sr25519::Public>("Alice"),
                    get_account_id_from_seed::<sr25519::Public>("Bob"),
                ],
                true,
            )
        },
        vec![],
        None,
        None,
        None,
        Default::default(),
    ))
}
