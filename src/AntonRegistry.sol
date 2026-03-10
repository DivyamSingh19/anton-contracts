// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract AntonRegistry {

    struct Protocol {
        address owner;
        bool active;
        uint256 registeredAt;
    }

    struct ContractInfo {
        address protocol;
        bool active;
        uint256 registeredAt;
    }
 
    mapping(address => Protocol) public protocols;
 
    mapping(address => ContractInfo) public contracts;
 
    mapping(address => address[]) public protocolContracts;
 
    event ProtocolRegistered(
        address indexed protocol,
        address indexed owner
    );

    event ContractRegistered(
        address indexed protocol,
        address indexed contractAddress
    );

    event ContractRemoved(
        address indexed contractAddress
    );

    event ProtocolDeactivated(
        address indexed protocol
    );
 
    modifier onlyProtocolOwner(address protocol) {
        require(
            protocols[protocol].owner == msg.sender,
            "Not protocol owner"
        );
        _;
    }

    modifier protocolExists(address protocol) {
        require(
            protocols[protocol].owner != address(0),
            "Protocol not registered"
        );
        _;
    }

    modifier contractExists(address contractAddress) {
        require(
            contracts[contractAddress].protocol != address(0),
            "Contract not registered"
        );
        _;
    }

    // ----------------------------------------------------
    // PROTOCOL REGISTRATION
    // ----------------------------------------------------

    function registerProtocol(address protocol) external {

        require(protocol != address(0), "Invalid protocol");

        require(
            protocols[protocol].owner == address(0),
            "Protocol already registered"
        );

        protocols[protocol] = Protocol({
            owner: msg.sender,
            active: true,
            registeredAt: block.timestamp
        });

        emit ProtocolRegistered(protocol, msg.sender);
    }

    // ----------------------------------------------------
    // CONTRACT REGISTRATION
    // ----------------------------------------------------

    function registerContract(
        address protocol,
        address contractAddress
    ) external protocolExists(protocol) onlyProtocolOwner(protocol) {

        require(contractAddress != address(0), "Invalid contract");

        require(
            contracts[contractAddress].protocol == address(0),
            "Contract already registered"
        );

        contracts[contractAddress] = ContractInfo({
            protocol: protocol,
            active: true,
            registeredAt: block.timestamp
        });

        protocolContracts[protocol].push(contractAddress);

        emit ContractRegistered(protocol, contractAddress);
    }

    // ----------------------------------------------------
    // CONTRACT MANAGEMENT
    // ----------------------------------------------------

    function deactivateContract(
        address contractAddress
    ) external contractExists(contractAddress) {

        address protocol = contracts[contractAddress].protocol;

        require(
            protocols[protocol].owner == msg.sender,
            "Not protocol owner"
        );

        contracts[contractAddress].active = false;

        emit ContractRemoved(contractAddress);
    }

    function deactivateProtocol(
        address protocol
    ) external protocolExists(protocol) onlyProtocolOwner(protocol) {

        protocols[protocol].active = false;

        emit ProtocolDeactivated(protocol);
    }

    // ----------------------------------------------------
    // VIEW FUNCTIONS
    // ----------------------------------------------------

    function isProtocolActive(
        address protocol
    ) external view returns (bool) {

        return protocols[protocol].active;
    }

    function isContractActive(
        address contractAddress
    ) external view returns (bool) {

        return contracts[contractAddress].active;
    }

    function getProtocolContracts(
        address protocol
    ) external view returns (address[] memory) {

        return protocolContracts[protocol];
    }

    function ownerOfProtocol(
        address protocol
    ) external view returns (address) {

        return protocols[protocol].owner;
    }

    function protocolOfContract(
        address contractAddress
    ) external view returns (address) {

        return contracts[contractAddress].protocol;
    }

}