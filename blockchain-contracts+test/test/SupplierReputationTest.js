const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("SupplierReputation Contract", function () {
  let SupplierReputation, supplierReputation;
  let admin, testSupplier;

  beforeEach(async function () {
    [admin, testEntity] = await ethers.getSigners();
  
    // Deploy ProvenanceRegistry
    const ProvenanceRegistry = await ethers.getContractFactory("ProvenanceRegistry");
    provenanceRegistry = await ProvenanceRegistry.deploy(admin.address);
    await provenanceRegistry.deployed(); // Ensure the deployment is complete
  
    // Deploy ShipmentTracking
    const ShipmentTracking = await ethers.getContractFactory("ShipmentTracking");
    shipmentTracking = await ShipmentTracking.deploy(1000, provenanceRegistry.address); // Pass correct address
    await shipmentTracking.deployed(); // Ensure the deployment is complete
  });
  

  it("Should update reputation based on feedback", async function () {
    // Register a supplier
    await supplierReputation.registerSupplier(
      testSupplier.address,
      "Test Supplier",
      "City, Country",
      "Electronics"
    );
  
    // Provide feedback
    await supplierReputation.receiveFeedback(testSupplier.address, 80);
  
    // Verify the updated reputation score
    const supplier = await supplierReputation.supplierDirectory(testSupplier.address);
    expect(supplier.reputationScore).to.equal(90); // (100 + 80) / 2 = 90
  });
  
  
  
});
