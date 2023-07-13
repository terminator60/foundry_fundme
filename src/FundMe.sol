// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe__notOwner();
error FundMe__withdrawFail();

contract FundMe {
    address[] internal s_funders;
    mapping(address => uint) internal s_addressToAmountFunded;
    uint256 public constant MINIMUM_USD = 50 * (10 ** 18);
    address private immutable i_owner;
    AggregatorV3Interface internal immutable i_priceFeed;

    using PriceConverter for uint256;

    event amountFunded(address funder, uint256 amountFunded);

    constructor(address _priceFeedAddress) {
        i_priceFeed = AggregatorV3Interface(_priceFeedAddress);
        i_owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert FundMe__notOwner();
        _;
    }

    function fund() public payable {
        require(msg.value.getEthConversionPrice(i_priceFeed) >= MINIMUM_USD);
        s_addressToAmountFunded[msg.sender] = msg.value;
        s_funders.push(msg.sender);
        emit amountFunded(msg.sender, msg.value);
    }

    function withdraw() public payable onlyOwner {
        for (uint256 index = 0; index < s_funders.length; index++) {
            s_addressToAmountFunded[s_funders[index]] = 0;
        }
        s_funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call Failed");
    }

    function withdrawCheaper() public payable onlyOwner {
        uint256 s_fundersLength = s_funders.length;
        for (uint256 index = 0; index < s_fundersLength; index++) {
            s_addressToAmountFunded[s_funders[index]] = 0;
        }
        s_funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        if (!callSuccess) revert FundMe__withdrawFail();
    }

    function getAddressToAmountFunded(
        address _funderAddress
    ) public view returns (uint256) {
        return s_addressToAmountFunded[_funderAddress];
    }

    function getFunders(uint256 _index) public view returns (address) {
        return s_funders[_index];
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
