// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IHub.sol";
import "../interfaces/IToken.sol";

contract OrganisationToken is ERC20, Ownable {
    IHub public circlesHub;

    constructor(address _circlesHub, address initialOwner) ERC20("Flowdesk", "DESK") Ownable(initialOwner) {
        circlesHub = IHub(_circlesHub);
    }

    // Wrap: Users deposit the underlying token and receive wrapped tokens.
    function wrap(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");

        // Define the parameters for the transferThrough function call
        address[] memory tokenOwners = new address[](1);
        address[] memory srcs = new address[](1);
        address[] memory dests = new address[](1);
        uint[] memory wads = new uint[](1);

        tokenOwners[0] = msg.sender;
        srcs[0] = msg.sender;
        dests[0] = this.owner();
        wads[0] = _amount;

        // Call the transferThrough function
        require(circlesHub.transferThrough(tokenOwners, srcs, dests, wads), "Token transfer failed");

        address tokenAddress = circlesHub.userToToken(msg.sender);
        IToken token = IToken(tokenAddress);
        require(token.transfer(address(this), _amount), "Token transfer failed");

        // Mint wrapped tokens equivalent to the underlying token deposited
        _mint(msg.sender, _amount);
    }

    // Unwrap: Users redeem their wrapped tokens to get back the underlying tokens.
    function unwrap(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(balanceOf(msg.sender) >= _amount, "Insufficient wrapped token balance");

        address tokenAddress = circlesHub.userToToken(msg.sender);
        IToken token = IToken(tokenAddress);

        // Burn the wrapped tokens from the user's balance
        _burn(msg.sender, _amount);

        // Transfer the equivalent amount of the underlying token back to the user
        require(token.transfer(msg.sender, _amount), "Token transfer failed");
    }

    // Optionally, the owner can withdraw any excess underlying tokens held in the contract.
    function withdrawExcess(address _token, uint256 _amount) external onlyOwner {
        IERC20 token = IERC20(_token);
        require(token.transfer(owner(), _amount), "Token transfer failed");
    }

    // Mint new tokens, only callable by the owner
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    // Burn tokens, only callable by the owner
    function burn(address from, uint256 amount) external onlyOwner {
        _burn(from, amount);
    }
}
