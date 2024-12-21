const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ProvenanceRegistry Contract", function () {
  let ProvenanceRegistry, provenanceRegistry;
  let admin, testEntity;

  beforeEach(async function () {
    [admin, testEntity] = await ethers.getSigners(); // Get test accounts
    ProvenanceRegistry = await ethers.getContractFactory("ProvenanceRegistry"); // Load contract factory
    provenanceRegistry = await ProvenanceRegistry.deploy(admin.address); // Deploy the contract
  });

  it("Should register an entity successfully", async function () {
    await provenanceRegistry.registerEntity(
      testEntity.address,
      "Test Entity",
      "1234567890",
      "City",
      "State",
      "Country"
    );

    const entity = await provenanceRegistry.entityDetails(testEntity.address);
    expect(entity.entityName).to.equal("Test Entity");
    expect(entity.isCertified).to.be.false;
  });

  it("Should emit an EntityRegistered event", async function () {
    await expect(
      provenanceRegistry.registerEntity(
        testEntity.address,
        "Test Entity",
        "1234567890",
        "City",
        "State",
        "Country"
      )
    )
      .to.emit(provenanceRegistry, "EntityRegistered")
      .withArgs(testEntity.address, "Test Entity");
  });

  it("Should certify an entity", async function () {
    await provenanceRegistry.registerEntity(
      testEntity.address,
      "Test Entity",
      "1234567890",
      "City",
      "State",
      "Country"
    );
    await provenanceRegistry.certifyEntity(testEntity.address);

    const entity = await provenanceRegistry.entityDetails(testEntity.address);
    expect(entity.isCertified).to.be.true;
  });

  it("Should allow a certified entity to register an item", async function () {
    await provenanceRegistry.registerEntity(
      testEntity.address,
      "Test Entity",
      "1234567890",
      "City",
      "State",
      "Country"
    );
    await provenanceRegistry.certifyEntity(testEntity.address);

    await provenanceRegistry
      .connect(testEntity)
      .registerItem("ITEM001", testEntity.address, "Origin Location", 100, 50);

    const item = await provenanceRegistry.itemRecords("ITEM001");
    expect(item.uniqueID).to.equal("ITEM001");
    expect(item.registeredBy).to.equal(testEntity.address);
    expect(item.availableUnits).to.equal(100);
    expect(item.pricePerUnit).to.equal(50);
  });

  it("Should allow a certified entity to update an item", async function () {
    await provenanceRegistry.registerEntity(
      testEntity.address,
      "Test Entity",
      "1234567890",
      "City",
      "State",
      "Country"
    );
    await provenanceRegistry.certifyEntity(testEntity.address);

    await provenanceRegistry
      .connect(testEntity)
      .registerItem("ITEM001", testEntity.address, "Origin Location", 100, 50);

    await provenanceRegistry
      .connect(testEntity)
      .updateItem("ITEM001", 80, 45);

    const item = await provenanceRegistry.itemRecords("ITEM001");
    expect(item.availableUnits).to.equal(80);
    expect(item.pricePerUnit).to.equal(45);
  });

  it("Should allow the admin to decrease item units", async function () {
    await provenanceRegistry.registerEntity(
      testEntity.address,
      "Test Entity",
      "1234567890",
      "City",
      "State",
      "Country"
    );
    await provenanceRegistry.certifyEntity(testEntity.address);

    await provenanceRegistry
      .connect(testEntity)
      .registerItem("ITEM001", testEntity.address, "Origin Location", 100, 50);

    await provenanceRegistry.decreaseUnits("ITEM001", 20);

    const item = await provenanceRegistry.itemRecords("ITEM001");
    expect(item.availableUnits).to.equal(80);
  });
});
