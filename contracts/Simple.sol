// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract FIRManagement {
    enum FIRStatus { Pending, Rejected, Approved, Investigated, Closed }

    struct FIR {
        uint256 id;
        address user;
        string details;
        FIRStatus status;
        string rejectionMessage;
        string investigationDetails;
        string courtMessage;
    }

    uint256 public firCounter;
    mapping(uint256 => FIR) public firs;
    mapping(address => string) public roles;

    modifier onlyRole(string memory role) {
        require(
            keccak256(abi.encodePacked(roles[msg.sender])) == keccak256(abi.encodePacked(role)),
            "Access denied: Incorrect role"
        );
        _;
    }

    // Events for tracking FIR updates
    event FIRCreated(uint256 firId, address user);
    event FIRStatusUpdated(uint256 firId, FIRStatus status, string message);

    constructor() {
        // Assign roles to predefined addresses for simplicity
        roles[msg.sender] = "Admin"; // Contract deployer is admin
    }

    // Assign role to an address (only Admin)
    function assignRole(address _address, string memory _role) public onlyRole("Admin") {
        roles[_address] = _role;
    }

    // User creates a new FIR
    function createFIR(string memory _details) public onlyRole("User") {
        firCounter++;
        firs[firCounter] = FIR(
            firCounter,
            msg.sender,
            _details,
            FIRStatus.Pending,
            "",
            "",
            ""
        );
        emit FIRCreated(firCounter, msg.sender);
    }

    // Police accepts or rejects FIR
    function updateFIRStatus(uint256 _firId, bool _isApproved, string memory _message) public onlyRole("Police") {
        FIR storage fir = firs[_firId];
        require(fir.status == FIRStatus.Pending, "FIR not in Pending state");

        if (_isApproved) {
            fir.status = FIRStatus.Approved;
        } else {
            fir.status = FIRStatus.Rejected;
            fir.rejectionMessage = _message;
        }
        emit FIRStatusUpdated(_firId, fir.status, _message);
    }

    // Investigator marks FIR as investigated
    function markAsInvestigated(uint256 _firId, string memory _details) public onlyRole("Investigator") {
        FIR storage fir = firs[_firId];
        require(fir.status == FIRStatus.Approved, "FIR not in Approved state");

        fir.status = FIRStatus.Investigated;
        fir.investigationDetails = _details;
        emit FIRStatusUpdated(_firId, fir.status, _details);
    }

    // Court closes the FIR
    function closeFIR(uint256 _firId, string memory _message) public onlyRole("Court") {
        FIR storage fir = firs[_firId];
        require(fir.status == FIRStatus.Investigated, "FIR not in Investigated state");

        fir.status = FIRStatus.Closed;
        fir.courtMessage = _message;
        emit FIRStatusUpdated(_firId, fir.status, _message);
    }

    // User views their FIR
    function viewFIR(uint256 _firId) public view returns (FIR memory) {
        FIR memory fir = firs[_firId];
        require(
            msg.sender == fir.user || keccak256(abi.encodePacked(roles[msg.sender])) != keccak256(abi.encodePacked("User")),
            "Access denied: Not your FIR"
        );
        return fir;
    }

    // View all FIRs (For Police)
    function viewAllFIRs() public view onlyRole("Police") returns (FIR[] memory) {
        uint256 totalFIRs = firCounter;
        FIR[] memory result = new FIR[](totalFIRs);
        uint256 counter = 0;

        for (uint256 i = 1; i <= totalFIRs; i++) {
            result[counter] = firs[i];
            counter++;
        }
        return result;
    }

    // View all FIRs for Investigator
    function viewAllFIRInvestigator() public view onlyRole("Investigator") returns (FIR[] memory) {
        uint256 totalFIRs = firCounter;
        uint256 count = 0;

        // Count the FIRs in Approved state
        for (uint256 i = 1; i <= totalFIRs; i++) {
            if (firs[i].status == FIRStatus.Approved) {
                count++;
            }
        }

        // Create an array for Approved FIRs
        FIR[] memory result = new FIR[](count);
        uint256 counter = 0;

        for (uint256 i = 1; i <= totalFIRs; i++) {
            if (firs[i].status == FIRStatus.Approved) {
                result[counter] = firs[i];
                counter++;
            }
        }
        return result;
    }
    function viewAllFIRCourt() public view onlyRole("Court") returns (FIR[] memory) {
        uint256 totalFIRs = firCounter;
        uint256 count = 0;

        // Count the FIRs in Approved state
        for (uint256 i = 1; i <= totalFIRs; i++) {
            if (firs[i].status == FIRStatus.Investigated) {
                count++;
            }
        }

        // Create an array for Approved FIRs
        FIR[] memory result = new FIR[](count);
        uint256 counter = 0;

        for (uint256 i = 1; i <= totalFIRs; i++) {
            if (firs[i].status == FIRStatus.Investigated) {
                result[counter] = firs[i];
                counter++;
            }
        }
        return result;
    }
}
