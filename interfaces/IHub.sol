// SPDX-License-Identifier: AGPL
pragma solidity ^0.8.0;

interface IHub {
    function tokenToUser(address token) external view returns (address);
    function userToToken(address user) external view returns (address);
    function transferThrough(
        address[] memory tokenOwners,
        address[] memory srcs,
        address[] memory dests,
        uint[] memory wads
    ) external returns (bool);
}