// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testUserCantFundLessThanMinimumUSD() external {
        vm.expectRevert();
        fundMe.fund();
    }

    function testUserCanFundAndUpdatesFundedDataStructure() external funded {
        assertEq(fundMe.getFunders(0), USER);
        assertEq(fundMe.getAddressToAmountFunded(USER), SEND_VALUE);
    }

    function testOnlyOwnerCanWithdraw() external funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithSingleFunder() external funded {
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        uint256 finalOwnerBalance = fundMe.getOwner().balance;
        uint256 finalFundMeBalance = address(fundMe).balance;
        assertEq(finalFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            finalOwnerBalance
        );
    }

    function testWithdrawWithMultipleFunder() external funded {
        uint160 numberOfFunders = 10;
        uint160 startingFundIndex = 1;
        for (uint160 i = startingFundIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 finalOwnerBalance = fundMe.getOwner().balance;
        uint256 finalFundMeBalance = address(fundMe).balance;
        assertEq(finalFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            finalOwnerBalance
        );
    }

    function testWithdrawCheaprWithMultipleFunder() external funded {
        uint160 numberOfFunders = 10;
        uint160 startingFundIndex = 1;
        for (uint160 i = startingFundIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdrawCheaper();

        uint256 finalOwnerBalance = fundMe.getOwner().balance;
        uint256 finalFundMeBalance = address(fundMe).balance;
        assertEq(finalFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            finalOwnerBalance
        );
    }
}
