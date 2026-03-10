// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DelegatedAuthority {
 
    struct TargetPermissions {
        address owner;
        bool active;
    }
 
    address public immutable kaizenExecutor;
 
    mapping(address => TargetPermissions) private targets;
 
    mapping(address => mapping(bytes4 => bool)) private permissions;
 
    mapping(address => mapping(address => bool)) public delegates;
 
    event TargetRegistered(
        address indexed target,
        address indexed owner
    );

    event PermissionGranted(
        address indexed target,
        bytes4 indexed selector
    );

    event PermissionRevoked(
        address indexed target,
        bytes4 indexed selector
    );

    event DelegateAdded(
        address indexed target,
        address indexed delegate
    );

    event DelegateRemoved(
        address indexed target,
        address indexed delegate
    );

    event TargetDeactivated(
        address indexed target
    );
 
    modifier onlyTargetOwner(address target) {
        require(
            msg.sender == targets[target].owner ||
            delegates[target][msg.sender],
            "Not authorized"
        );
        _;
    }

    modifier onlyExecutor() {
        require(
            msg.sender == kaizenExecutor,
            "Not Kaizen executor"
        );
        _;
    }

    modifier targetExists(address target) {
        require(
            targets[target].owner != address(0),
            "Target not registered"
        );
        _;
    }
 
    constructor(address _executor) {
        require(_executor != address(0), "Invalid executor");
        kaizenExecutor = _executor;
    }
 
    function registerTarget(address target) external {

        require(target != address(0), "Invalid target");

        require(
            targets[target].owner == address(0),
            "Already registered"
        );

        targets[target] = TargetPermissions({
            owner: msg.sender,
            active: true
        });

        emit TargetRegistered(target, msg.sender);
    }
 
    function addDelegate(
        address target,
        address delegate
    ) external targetExists(target) onlyTargetOwner(target) {

        require(delegate != address(0), "Invalid delegate");

        delegates[target][delegate] = true;

        emit DelegateAdded(target, delegate);
    }

    function removeDelegate(
        address target,
        address delegate
    ) external targetExists(target) onlyTargetOwner(target) {

        delegates[target][delegate] = false;

        emit DelegateRemoved(target, delegate);
    }
 
    function grantPermission(
        address target,
        bytes4 selector
    ) external targetExists(target) onlyTargetOwner(target) {

        permissions[target][selector] = true;

        emit PermissionGranted(target, selector);
    }

    function revokePermission(
        address target,
        bytes4 selector
    ) external targetExists(target) onlyTargetOwner(target) {

        permissions[target][selector] = false;

        emit PermissionRevoked(target, selector);
    }

 
    function canExecute(
        address target,
        bytes4 selector
    ) external view returns (bool) {

        if(!targets[target].active) {
            return false;
        }

        return permissions[target][selector];
    }

  
    function deactivateTarget(
        address target
    ) external targetExists(target) onlyTargetOwner(target) {

        targets[target].active = false;

        emit TargetDeactivated(target);
    }
    function ownerOf(
        address target
    ) external view returns (address) {

        return targets[target].owner;
    }

    function isDelegate(
        address target,
        address user
    ) external view returns (bool) {

        return delegates[target][user];
    }

    function isPermissionGranted(
        address target,
        bytes4 selector
    ) external view returns (bool) {

        return permissions[target][selector];
    }
}