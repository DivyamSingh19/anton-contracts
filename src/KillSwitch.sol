// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IDelegatedAuthority {
    function canExecute(address target, bytes4 selector) external view returns (bool);
    function ownerOf(address target) external view returns (address);
}

contract KillSwitch {

    IDelegatedAuthority public authority;

    address public immutable kaizenExecutor;

    uint256 public constant COOLDOWN = 5 minutes;

    mapping(address => uint256) public lastTriggered;

    event KillSwitchTriggered(
        address indexed target,
        address indexed executor,
        bytes4 selector,
        uint256 timestamp
    );

    event ProtocolResumed(
        address indexed target,
        address indexed owner
    );

    modifier onlyExecutor() {
        require(msg.sender == kaizenExecutor, "Not Kaizen executor");
        _;
    }

    modifier onlyOwner(address target) {
        require(
            msg.sender == authority.ownerOf(target),
            "Not protocol owner"
        );
        _;
    }

    constructor(
        address _authority,
        address _executor
    ) {
        require(_authority != address(0), "Invalid authority");
        require(_executor != address(0), "Invalid executor");

        authority = IDelegatedAuthority(_authority);
        kaizenExecutor = _executor;
    }

    function triggerKillSwitch(
        address target,
        bytes calldata pauseCallData
    ) external onlyExecutor {

        bytes4 selector;

        assembly {
            selector := calldataload(pauseCallData.offset)
        }

        require(
            authority.canExecute(target, selector),
            "Selector not permitted"
        );

        require(
            block.timestamp > lastTriggered[target] + COOLDOWN,
            "Cooldown active"
        );

        (bool success,) = target.call(pauseCallData);

        require(success, "Pause execution failed");

        lastTriggered[target] = block.timestamp;

        emit KillSwitchTriggered(
            target,
            msg.sender,
            selector,
            block.timestamp
        );
    }

    function resumeProtocol(
        address target,
        bytes calldata resumeCallData
    ) external onlyOwner(target) {

        (bool success,) = target.call(resumeCallData);

        require(success, "Resume failed");

        emit ProtocolResumed(
            target,
            msg.sender
        );
    }

}