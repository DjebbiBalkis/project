const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ShipmentTracking Contract", function () {
  let deploymentManager, provenanceRegistry, shipmentTracking, supplierReputation;
  let admin, testEntity;

  beforeEach(async function () {
    [admin, testEntity] = await ethers.getSigners();

    // Deploy DeploymentManager
    const DeploymentManager = await ethers.getContractFactory("DeploymentManager");
    deploymentManager = await DeploymentManager.deploy();
    await deploymentManager.deployed();

    // Get deployed contract instances
    const addresses = await deploymentManager.getDeployedAddresses();
    provenanceRegistry = await ethers.getContractAt("ProvenanceRegistry", addresses[0]);
    shipmentTracking = await ethers.getContractAt("ShipmentTracking", addresses[1]);
    supplierReputation = await ethers.getContractAt("SupplierReputation", addresses[2]);
  });

  it("Should record a shipment successfully", async function () {
    // Register an entity in ProvenanceRegistry
    await provenanceRegistry.registerEntity(
      testEntity.address,
      "Test Entity",
      "1234567890",
      "City",
      "State",
      "Country"
    );

    // Certify the entity
    await provenanceRegistry.certifyEntity(testEntity.address);

    // Register an item in ProvenanceRegistry
    await provenanceRegistry
      .connect(testEntity)
      .registerItem("ITEM001", testEntity.address, "Origin Location", 100, 50);

    // Record the shipment in ShipmentTracking
    await shipmentTracking.recordShipment(
      "SHIPMENT001",
      "ITEM001",
      10,
      "123 Destination Street"
    );

    const shipment = await shipmentTracking.shipmentRecords("SHIPMENT001");
    expect(shipment.itemName).to.equal("ITEM001");
    expect(shipment.itemQuantity).to.equal(10);
    expect(shipment.destinationAddress).to.equal("123 Destination Street");
    expect(shipment.isDelivered).to.be.false;
  });

  it("Should confirm delivery and transfer tokens", async function () {
    // Register an entity in ProvenanceRegistry
    await provenanceRegistry.registerEntity(
      testEntity.address,
      "Test Entity",
      "1234567890",
      "City",
      "State",
      "Country"
    );

    // Certify the entity
    await provenanceRegistry.certifyEntity(testEntity.address);

    // Register an item in ProvenanceRegistry
    await provenanceRegistry
      .connect(testEntity)
      .registerItem("ITEM001", testEntity.address, "Origin Location", 100, 50);

    // Record the shipment
    await shipmentTracking.recordShipment(
      "SHIPMENT001",
      "ITEM001",
      10,
      "123 Destination Street"
    );

    // Confirm delivery
    await shipmentTracking.confirmDelivery("SHIPMENT001");

    const shipment = await shipmentTracking.shipmentRecords("SHIPMENT001");
    expect(shipment.isDelivered).to.be.true;
  });
});
