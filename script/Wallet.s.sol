// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/Admin.sol";
import "../src/Engineer.sol";
import "../src/User.sol";
import "../src/Organization.sol";

contract Deploy is Script{
    function run() external {
        vm.startBroadcast();
          UserWalletRegistry userwallet = new UserWalletRegistry();
          EngineerWalletRegistry engineerWallet = new EngineerWalletRegistry();
          AdminWalletRegistry adminWallet = new AdminWalletRegistry();
          OrganizationWalletRegistry orgWallet = new OrganizationWalletRegistry();

        vm.stopBroadcast();

    }
}