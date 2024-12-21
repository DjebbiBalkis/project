async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);
  
    // Deploy ProvenanceRegistry contract
    const ProvenanceRegistry = await ethers.getContractFactory("ProvenanceRegistry");
    const provenanceRegistry = await ProvenanceRegistry.deploy(deployer.address);
    
    // Log transaction hash for ProvenanceRegistry deployment
    console.log("Transaction Hash for ProvenanceRegistry deployment:", provenanceRegistry.deployTransaction.hash);
  
    // Wait for the transaction to be mined
    const txReceipt = await provenanceRegistry.deployTransaction.wait();
    console.log("ProvenanceRegistry Contract deployed. Block number:", txReceipt.blockNumber);
    console.log("ProvenanceRegistry deployed to:", provenanceRegistry.address);
  
    // Ensure the address is valid
    if (!provenanceRegistry.address || provenanceRegistry.address === '0x0000000000000000000000000000000000000000') {
      console.error("ProvenanceRegistry deployment failed, invalid address.");
      process.exit(1); // Exit if the deployment fails
    }
  
    // Deploy ShipmentTracking contract, passing the address of ProvenanceRegistry
    const ShipmentTracking = await ethers.getContractFactory("ShipmentTracking");
    const shipmentTracking = await ShipmentTracking.deploy(1000, provenanceRegistry.address);
    
    // Log transaction hash for ShipmentTracking deployment
    console.log("Transaction Hash for ShipmentTracking deployment:", shipmentTracking.deployTransaction.hash);
  
    // Wait for the transaction to be mined for ShipmentTracking
    const shipmentTrackingTxReceipt = await shipmentTracking.deployTransaction.wait();
    console.log("ShipmentTracking Contract deployed. Block number:", shipmentTrackingTxReceipt.blockNumber);
    console.log("ShipmentTracking deployed to:", shipmentTracking.address);
  
    // Deploy SupplierReputation contract
    const SupplierReputation = await ethers.getContractFactory("SupplierReputation");
    const supplierReputation = await SupplierReputation.deploy();
    console.log("SupplierReputation deployed to:", supplierReputation.address);
  
    // Deploy DeploymentManager contract
    const DeploymentManager = await ethers.getContractFactory("DeploymentManager");
    const deploymentManager = await DeploymentManager.deploy();
    console.log("DeploymentManager deployed to:", deploymentManager.address);
  
    // Get deployed addresses from DeploymentManager
    const addresses = await deploymentManager.getDeployedAddresses();
    console.log("Deployed addresses from DeploymentManager:");
    console.log("ProvenanceRegistry:", addresses[0]);
    console.log("ShipmentTracking:", addresses[1]);
    console.log("SupplierReputation:", addresses[2]);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
  