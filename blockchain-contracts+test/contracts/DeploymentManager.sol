// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./ProvenanceRegistry.sol";
import "./ShipmentTracking.sol";
import "./SupplierReputation.sol";

contract DeploymentManager {
    ProvenanceRegistry public provenanceRegistry;
    ShipmentTracking public shipmentTracking;
    SupplierReputation public supplierReputation;

    constructor() {
        // Deploy ProvenanceRegistry
        provenanceRegistry = new ProvenanceRegistry(msg.sender);

        // Deploy ShipmentTracking and link it to ProvenanceRegistry
        shipmentTracking = new ShipmentTracking(1000, address(provenanceRegistry));

        // Deploy SupplierReputation
        supplierReputation = new SupplierReputation();
    }

    // Expose the addresses for testing and deployment
    function getDeployedAddresses()
        public
        view
        returns (
            address,
            address,
            address
        )
    {
        return (address(provenanceRegistry), address(shipmentTracking), address(supplierReputation));
    }
}
