// SPDX-License-Identifier: MIT
use sp_runtime::traits::{BlakeTwo256, IdentityLookup};
use frame_support::construct_runtime;

pub type Block = sp_runtime::generic::Block<Header, UncheckedExtrinsic>;
pub type Header = sp_runtime::generic::Header<u32, BlakeTwo256>;

construct_runtime!(
    pub enum Runtime where
        Block = Block,
        NodeBlock = Block,
        UncheckedExtrinsic = UncheckedExtrinsic,
    {
        System: frame_system,
        Balances: pallet_balances,
        Provenance: pallet_provenance,
    }
);
