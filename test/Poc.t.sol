// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {YieldFarmToken, MultiTokenYieldFarm, IERC20} from "../src/MultiTokenYieldFarm.sol";

contract Poc is Test {
    MultiTokenYieldFarm farm;
    YieldFarmToken yft;

    ERC20Mock uniswapLpToken;
    ERC20Mock sushiswapLpToken;
    ERC20Mock uniswapPoolBonusToken;
    ERC20Mock sushiswapPoolBonusToken;

    address owner;
    address collector;
    address alice;
    address bob;
    address clara;
    address dan;
    address yc;

    uint256 INITIAL_REWARD_PER_BLOCK = 100e18;
    uint256 START_BLOCK = 100;

    function _tokenSetup() internal {
        // mint lp tokens
        uniswapLpToken.mint(alice, 1000e18);
        sushiswapLpToken.mint(bob, 1000e18);

        // mint bonus tokens
        uniswapPoolBonusToken.mint(owner, 1000e18);
        sushiswapPoolBonusToken.mint(owner, 1000e18);

        // approvals
        vm.prank(alice);
        uniswapLpToken.approve(address(farm), 1000e18);

        vm.prank(bob);
        sushiswapLpToken.approve(address(farm), 1000e18);
    }

    function _addUniswapPool() internal {
        vm.prank(owner);
        farm.add(1000, uniswapLpToken, 0, 0, 1 days, true);
    }

    function _addSushiswapPool() internal {
        vm.prank(owner);
        farm.add(500, sushiswapLpToken, 200, 1, 1 weeks, false);
    }

    function setUp() public {
        owner = makeAddr("owner");
        collector = makeAddr("fee collector");
        alice = makeAddr("user 1");
        bob = makeAddr("user 2");
        clara = makeAddr("referrer 1");
        dan = makeAddr("referrer 2");
        yc = makeAddr("attacker");

        uniswapLpToken = new ERC20Mock();
        sushiswapLpToken = new ERC20Mock();
        uniswapPoolBonusToken = new ERC20Mock();
        sushiswapPoolBonusToken = new ERC20Mock();

        vm.startPrank(owner);
        yft = new YieldFarmToken();
        vm.roll(START_BLOCK - 10); // Start before the farming begins
        farm = new MultiTokenYieldFarm(yft, INITIAL_REWARD_PER_BLOCK, START_BLOCK);
        yft.addMinter(address(farm));
        farm.setFeeCollector(collector);
        vm.stopPrank();

        _tokenSetup();
        _addUniswapPool();
        _addSushiswapPool();
    }
}
