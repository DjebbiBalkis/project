// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IProvenanceRegistry {
    function decreaseUnits(string memory itemID, uint256 quantity) external;
    function viewItem(string memory itemID) external view returns (address registeredBy, uint256 timestamp, string memory originLocation, uint256 availableUnits, uint256 pricePerUnit);
}

contract ShipmentTracking {
    struct Package {
        string itemName;
        uint256 itemQuantity;
        string destinationAddress;
        uint256 shipmentTime;
        address senderAddress;
        bool isDelivered;
        uint256 totalPrice;  // Total price calculation
        uint256 shippingCost;  // Dynamic shipping cost
    }

    address public contractOwner;
    uint256 public totalTokens;
    mapping(address => uint256) public accountBalances;
    mapping(string => Package) public shipmentRecords;

    IProvenanceRegistry public provenanceRegistryContract;

    event TokensTransferred(address indexed from, address indexed to, uint256 amount);
    event PackageShipped(string packageId, address indexed sender, string destination);
    event PackageDelivered(string packageId, address indexed receiver, uint256 payment);
    event ShipmentDeleted(string packageId);
    event ShippingCostCalculated(string packageId, uint256 cost);

    modifier onlyOwner() {
        require(msg.sender == contractOwner, "Action restricted to contract owner.");
        _;
    }

    constructor(uint256 initialSupply, address _provenanceRegistryContract) {
        contractOwner = msg.sender;
        totalTokens = initialSupply;
        accountBalances[contractOwner] = initialSupply;
        provenanceRegistryContract = IProvenanceRegistry(_provenanceRegistryContract);
    }

    function transferTokens(address recipient, uint256 amount) public {
        require(accountBalances[msg.sender] >= amount, "Insufficient balance for transfer.");
        accountBalances[msg.sender] -= amount;
        accountBalances[recipient] += amount;
        emit TokensTransferred(msg.sender, recipient, amount);
    }

    function calculateShippingCost(string memory destination) internal pure returns (uint256) {
        // Placeholder: shipping cost based on destination
        return bytes(destination).length * 10; 

    }

    function recordShipment(
    string memory packageId,
    string memory itemName,
    uint256 quantity,
    string memory destination
) public {
    ( , , , uint256 availableUnits, uint256 pricePerUnit) = provenanceRegistryContract.viewItem(itemName);

    // Debugging statements
    require(availableUnits >= quantity, "Not enough units available for shipment.");

    uint256 totalPrice = pricePerUnit * quantity;
    uint256 shippingCost = calculateShippingCost(destination);

    shipmentRecords[packageId] = Package(
        itemName,
        quantity,
        destination,
        block.timestamp,
        msg.sender,
        false,
        totalPrice,
        shippingCost
    );

    emit PackageShipped(packageId, msg.sender, destination);
    emit ShippingCostCalculated(packageId, shippingCost);
}


    function confirmDelivery(string memory packageId) public {
        Package storage packageDetails = shipmentRecords[packageId];
        require(!packageDetails.isDelivered, "Package already marked as delivered.");

        packageDetails.isDelivered = true;

        provenanceRegistryContract.decreaseUnits(packageDetails.itemName, packageDetails.itemQuantity);

        uint256 paymentAmount = packageDetails.totalPrice + packageDetails.shippingCost;  // Including shipping cost
        transferTokens(packageDetails.senderAddress, paymentAmount);
        emit PackageDelivered(packageId, msg.sender, paymentAmount);
    }

    function viewShipmentDetails(string memory packageId)
        public
        view
        returns (
            string memory itemName,
            uint256 itemQuantity,
            string memory destinationAddress,
            uint256 shipmentTime,
            address senderAddress,
            bool isDelivered,
            uint256 totalPrice,
            uint256 shippingCost
        ) {
        Package memory packageDetails = shipmentRecords[packageId];
        return (
            packageDetails.itemName,
            packageDetails.itemQuantity,
            packageDetails.destinationAddress,
            packageDetails.shipmentTime,
            packageDetails.senderAddress,
            packageDetails.isDelivered,
            packageDetails.totalPrice,
            packageDetails.shippingCost
        );
    }
}
