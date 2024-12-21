// SPDX-License-Identifier: MIT
#![cfg_attr(not(feature = "std"), no_std)]

pub mod runtime;
pub mod genesis;

// Export runtime API for the relay chain
pub use crate::runtime::Runtime;
