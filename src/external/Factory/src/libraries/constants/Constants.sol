// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.17;

uint256 constant ONE = 1e12;

uint256 constant BORROWS_SCALER = type(uint72).max * ONE; // uint72 is from the type of borrowIndex in `Ledger`

uint256 constant MIN_SIGMA = 0.01e18;

// To avoid underflow in `BalanceSheet.computeProbePrices`, ensure that `MAX_SIGMA * Borrower.B <= 1e18`
uint256 constant MAX_SIGMA = 0.18e18;

uint256 constant MIN_RESERVE_FACTOR = 4; // Expressed as reciprocal, e.g. 4 --> 25%

uint256 constant MAX_RESERVE_FACTOR = 20; // Expressed as reciprocal, e.g. 20 --> 5%

// 1 + 1 / MAX_LEVERAGE should correspond to the maximum feasible single-block accrualFactor so that liquidators have time to respond to interest updates
uint256 constant MAX_LEVERAGE = 200;

uint256 constant LIQUIDATION_INCENTIVE = 20; // Expressed as reciprocal, e.g. 20 --> 5%

uint256 constant LIQUIDATION_GRACE_PERIOD = 2 minutes;

uint256 constant IV_SCALE = 24 hours;

uint256 constant IV_CHANGE_PER_SECOND = 5e12;

uint256 constant FEE_GROWTH_GLOBALS_SAMPLE_PERIOD = 1 minutes;

uint32 constant ORACLE_LOOKBACK = 20 minutes;
