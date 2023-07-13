// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address priceFeed;
    }

    NetworkConfig public activeNetworkConfig;
    uint8 constant DECIMALS = 10;
    int256 constant INITIAL_PRICE = 2000e8;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaNetworkConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthNetworkConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilNetworkConfig();
        }
    }

    function getSepoliaNetworkConfig()
        public
        pure
        returns (NetworkConfig memory sepoliaNetworkConfig)
    {
        sepoliaNetworkConfig = NetworkConfig(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
    }

    function getMainnetEthNetworkConfig()
        public
        pure
        returns (NetworkConfig memory mainnetEthNetworkConfig)
    {
        mainnetEthNetworkConfig = NetworkConfig(
            0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        );
    }

    function getOrCreateAnvilNetworkConfig()
        public
        returns (NetworkConfig memory anvilNetworkConfig)
    {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();
        anvilNetworkConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
    }
}
