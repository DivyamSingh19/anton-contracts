// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "../src/Interfaces/IDelegatedAuthority.sol";
contract AntonTimelock {

    IDelegatedAuthority public authority;

    address public kaizenExecutor;

    uint256 public constant DEFAULT_LOCK_DURATION = 60 minutes;
    uint256 public constant MAX_LOCK_DURATION = 6 hours;

    // target => timestamp when lock expires
    mapping(address => uint256) public lockedUntil;

    // configurable lock duration per contract
    mapping(address => uint256) public lockDuration;

    event TimelockTriggered(
        address indexed target,
        address indexed executor,
        uint256 unlockTime
    );

    event TimelockDurationUpdated(
        address indexed target,
        uint256 duration
    );

    event ManualUnlock(
        address indexed target,
        address indexed owner
    );

    constructor(
        address _authority,
        address _executor
    ) {
        authority = IDelegatedAuthority(_authority);
        kaizenExecutor = _executor;
    }

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

    function triggerTimelock(
        address target,
        bytes calldata callData
    ) external onlyExecutor {

        bytes4 selector;

        assembly {
            selector := calldataload(callData.offset)
        }

        require(
            authority.canExecute(target, selector),
            "Selector not permitted"
        );

        require(
            block.timestamp >= lockedUntil[target],
            "Already locked"
        );

        (bool success,) = target.call(callData);

        require(success, "Execution failed");

        uint256 duration = lockDuration[target];

        if(duration == 0) {
            duration = DEFAULT_LOCK_DURATION;
        }

        lockedUntil[target] = block.timestamp + duration;

        emit TimelockTriggered(
            target,
            msg.sender,
            lockedUntil[target]
        );
    }

    function setLockDuration(
        address target,
        uint256 duration
    ) external onlyOwner(target) {

        require(
            duration > 0 && duration <= MAX_LOCK_DURATION,
            "Invalid duration"
        );

        lockDuration[target] = duration;

        emit TimelockDurationUpdated(target, duration);
    }

    function manualUnlock(
        address target
    ) external onlyOwner(target) {

        require(
            lockedUntil[target] > block.timestamp,
            "Not locked"
        );

        lockedUntil[target] = block.timestamp;

        emit ManualUnlock(
            target,
            msg.sender
        );
    }

    function isLocked(
        address target
    ) external view returns (bool) {

        return block.timestamp < lockedUntil[target];
    }

}