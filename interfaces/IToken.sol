// SPDX-License-Identifier: AGPL
pragma solidity ^0.8.0;

interface IToken {
    function time() external view returns (uint256);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function period() external view returns (uint256);
    function periods() external view returns (uint256);
    function timeout() external view returns (uint256);
    function periodsWhenLastTouched() external view returns (uint256);
    function hubDeployedAt() external view returns (uint256);
    function stop() external;
    function stopped() external view returns (bool);
    function findInflationOffset() external view returns (uint256);
    function look() external view returns (uint256);
    function update() external;
    function hubTransfer(address from, address to, uint256 amount) external returns (bool);
    function transfer(address dst, uint256 wad) external returns (bool);
}