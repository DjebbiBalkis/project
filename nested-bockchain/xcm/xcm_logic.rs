// SPDX-License-Identifier: MIT
use xcm::v1::{MultiLocation, Xcm};
use xcm_executor::traits::SendXcm;

pub fn send_message(destination: MultiLocation, message: Xcm) -> Result<(), &'static str> {
    xcm_executor::send(destination, message)
}
