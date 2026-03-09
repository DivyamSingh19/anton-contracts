// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EngineerWalletRegistry {
    mapping(bytes32 => address) public accountWallet;
    mapping(address=> bytes32) public walletAccount;

    event WalletLinked(bytes32 accountId, address wallet);
    event WalletRemoved(bytes32 accountId, address wallet);
    function linkWallet(bytes32 accountId) external{
        address oldWallet = accountWallet[accountId];
        if(oldWallet != address(0)){
            delete walletAccount[oldWallet];
            emit WalletRemoved(accountId, oldWallet);
        }
        accountWallet[accountId] = msg.sender;
        walletAccount[msg.sender] = accountId;
        emit WalletLinked(accountId, msg.sender);
    }
    function removeWallet(bytes32 accountId) external{
        address wallet = accountWallet[accountId];
        require(wallet!= address(0),"No wallet linked");
        delete walletAccount[wallet];
        delete accountWallet[accountId];
        emit WalletRemoved(accountId, wallet);
    }
    function getWallet(bytes32 accountId) external view returns (address){
        return accountWallet[accountId];
    }
    function getAccount(address wallet) external view returns(bytes32){
        return walletAccount[wallet];
    }

}