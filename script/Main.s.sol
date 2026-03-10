// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";

import "../src/AntonRegistry.sol";
import "../src/KillSwitch.sol";
import "../src/DelegatedAuthority.sol";
import "../src/AntonTimeLock.sol";
import "forge-std/console.sol";
contract Deploy is Script {

    function run() external {

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        address executor = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);
 
        AntonRegistry registry = new AntonRegistry();
        console.log("Registry:", address(registry));
 
        DelegatedAuthority delegatedAuthority =
            new DelegatedAuthority(executor);
        console.log("DelegatedAuthority:", address(delegatedAuthority));
 
        KillSwitch killSwitch =
            new KillSwitch(address(delegatedAuthority), executor);
        console.log("KillSwitch:", address(killSwitch));
        AntonTimelock timeLock =
            new AntonTimelock(address(delegatedAuthority), executor);
         console.log("Timelock:", address(timeLock));
        vm.stopBroadcast();
    }
}