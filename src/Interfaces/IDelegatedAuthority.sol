// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IDelegatedAuthority {

    function canExecute(
        address target,
        bytes4 selector
    ) external view returns (bool);

    function ownerOf(
        address target
    ) external view returns (address);

}