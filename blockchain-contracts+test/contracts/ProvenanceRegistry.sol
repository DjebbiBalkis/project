// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IShipmentTracking {
    function confirmDelivery(string memory packageId) external;
}

contract ProvenanceRegistry {
    struct Entity {
        string entityName;
        string contactNumber;
        string city;
        string state;
        string country;
        bool isCertified;
    }

    struct Item {
        string uniqueID;
        address registeredBy;
        uint256 timestamp;
        string originLocation;
        uint256 availableUnits;
        uint256 pricePerUnit;
    }

    address public adminAccount;
    mapping(address => Entity) public entityDetails;
    mapping(string => Item) public itemRecords;

    IShipmentTracking public shipmentTrackingContract;  // Link to Shipment Tracking Contract

    event EntityRegistered(address indexed entityAddress, string name);
    event EntityCertified(address indexed entityAddress);
    event ItemRegistered(string itemID, address indexed registeredBy);
    event ItemUpdated(string itemID, uint256 newAvailableUnits, uint256 newPricePerUnit);
    event ItemRemoved(string itemID);
    event EntityRemoved(address indexed entityAddress);
    event UnitsDecreased(string itemID, uint256 remainingUnits);
    event ChangeLog(string indexed action, string itemID, address entity, uint256 timestamp);

    modifier onlyAdmin() {
        require(msg.sender == adminAccount, "Only admin can execute this action.");
        _;
    }

    modifier onlyCertifiedEntity(address entityAddress) {
        require(entityDetails[entityAddress].isCertified, "Entity must be certified.");
        _;
    }

    constructor(address _shipmentTrackingContract) {
        adminAccount = msg.sender;
        shipmentTrackingContract = IShipmentTracking(_shipmentTrackingContract);  // Set Shipment Tracking Contract address
    }

    // Logging each change to track modifications for audit purposes
    function logChange(string memory action, string memory itemID, address entity) internal {
        emit ChangeLog(action, itemID, entity, block.timestamp);
    }

    function registerEntity(
        address entityAddress,
        string memory name,
        string memory contact,
        string memory city,
        string memory state,
        string memory country
    ) public onlyAdmin {
        entityDetails[entityAddress] = Entity(name, contact, city, state, country, false);
        emit EntityRegistered(entityAddress, name);
        logChange("EntityRegistered", "", entityAddress);
    }

    function certifyEntity(address entityAddress) public onlyAdmin {
        entityDetails[entityAddress].isCertified = true;
        emit EntityCertified(entityAddress);
        logChange("EntityCertified", "", entityAddress);
    }

    function registerItem(
        string memory itemID,
        address entityAddress,
        string memory origin,
        uint256 availableUnits,
        uint256 pricePerUnit
    ) public onlyCertifiedEntity(entityAddress) {
        itemRecords[itemID] = Item(itemID, entityAddress, block.timestamp, origin, availableUnits, pricePerUnit);
        emit ItemRegistered(itemID, entityAddress);
        logChange("ItemRegistered", itemID, entityAddress);
    }

    function updateItem(
        string memory itemID,
        uint256 newAvailableUnits,
        uint256 newPricePerUnit
    ) public onlyCertifiedEntity(msg.sender) {
        Item storage item = itemRecords[itemID];
        item.availableUnits = newAvailableUnits;
        item.pricePerUnit = newPricePerUnit;
        emit ItemUpdated(itemID, newAvailableUnits, newPricePerUnit);
        logChange("ItemUpdated", itemID, msg.sender);
    }

    function removeItem(string memory itemID) public onlyAdmin {
        delete itemRecords[itemID];
        emit ItemRemoved(itemID);
        logChange("ItemRemoved", itemID, msg.sender);
    }

    function decreaseUnits(string memory itemID, uint256 quantity) public onlyAdmin {
        Item storage item = itemRecords[itemID];
        require(item.availableUnits >= quantity, "Not enough units available.");
        item.availableUnits -= quantity;
        emit UnitsDecreased(itemID, item.availableUnits);
        logChange("UnitsDecreased", itemID, msg.sender);
    }

    function viewItem(string memory itemID)
        public
        view
        returns (
            address registeredBy,
            uint256 timestamp,
            string memory originLocation,
            uint256 availableUnits,
            uint256 pricePerUnit
        ) {
        Item memory item = itemRecords[itemID];
        return (item.registeredBy, item.timestamp, item.originLocation, item.availableUnits, item.pricePerUnit);
    }
}
