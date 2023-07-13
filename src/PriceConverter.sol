// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getEthUsdPrice(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price * 10 ** 10);
    }

    function getEthConversionPrice(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getEthUsdPrice(priceFeed);
        uint256 ethAmountInUsd = (ethAmount * ethPrice) / (10 ** 18);
        return ethAmountInUsd;
    }
}
