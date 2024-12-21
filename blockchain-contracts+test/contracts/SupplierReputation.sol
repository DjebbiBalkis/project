// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract SupplierReputation {
    struct Supplier {
        string supplierName;
        string supplierLocation;
        string productCategory;
        uint256 reputationScore;
        uint256 feedbackCount;
    }

    address public adminUser;
    mapping(address => Supplier) public supplierDirectory;

    event SupplierRegistered(address indexed supplier, string name, string category);
    event ReputationUpdated(address indexed supplier, uint256 reputationScore);
    event FeedbackReceived(address indexed supplier, uint256 feedbackScore);

    modifier onlyAdmin() {
        require(msg.sender == adminUser, "Restricted to admin user.");
        _;
    }

    constructor() {
        adminUser = msg.sender;
    }

    function registerSupplier(
        address supplierAddress,
        string memory name,
        string memory location,
        string memory category
    ) public onlyAdmin {
        supplierDirectory[supplierAddress] = Supplier(name, location, category, 100, 0);  // Default reputation score 100
        emit SupplierRegistered(supplierAddress, name, category);
    }

    function updateReputation(address supplierAddress, uint256 newReputation) public onlyAdmin {
        supplierDirectory[supplierAddress].reputationScore = newReputation;
        emit ReputationUpdated(supplierAddress, newReputation);
    }

  function receiveFeedback(address supplierAddress, uint256 feedbackScore) public {
    Supplier storage supplier = supplierDirectory[supplierAddress];
    uint256 newReputation;

    if (supplier.feedbackCount == 0) {
        // For the first feedback, average the default score and feedback score
        newReputation = (supplier.reputationScore + feedbackScore) / 2;
    } else {
        // Weighted average for subsequent feedbacks
        newReputation = (supplier.reputationScore * supplier.feedbackCount + feedbackScore) / (supplier.feedbackCount + 1);
    }

    supplier.reputationScore = newReputation; // Update reputation
    supplier.feedbackCount++; // Increment feedback count
    emit FeedbackReceived(supplierAddress, feedbackScore); // Emit event
}

    function getSupplierReputation(address supplierAddress) public view returns (uint256 reputationScore) {
        return supplierDirectory[supplierAddress].reputationScore;
    }
}

