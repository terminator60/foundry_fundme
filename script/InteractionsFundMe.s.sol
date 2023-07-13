// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";

contract FundFundMe is Script {
    uint256 SEND_VALUE = 0.1 ether;

    function fundFundMe(address _fundMeAddress) public {
        FundMe(payable(_fundMeAddress)).fund{value: SEND_VALUE}();
        console.log("Funded FundMe with %s", SEND_VALUE);
    }

    function run() external {
        address fundMeAddress = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        vm.startBroadcast();
        fundFundMe(fundMeAddress);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    function run() external {
        address fundMeAddress = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        withdrawFundMe(fundMeAddress);
    }

    function withdrawFundMe(address _fundMeAddress) public {
        vm.startBroadcast();
        FundMe(payable(_fundMeAddress)).withdraw();
        vm.stopBroadcast();
        console.log("Withdraw FundMe balance!");
    }
}
