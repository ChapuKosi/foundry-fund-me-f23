// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConvertor} from "./PriceConvertor.sol";

error FundMe__NotOwner();

contract FundMe{
    using PriceConvertor for uint256;

    mapping(address => uint256) private s_addressToAmountFunded;
    address[] private s_funders;

    address private immutable i_owner;
    uint256 public constant MINIMUM_USD = 5e18;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }
      
    function fund() public payable {
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "didn't sent enough ETH"); // 1e18 = 1 ETH
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function getVersion() public view returns (uint256){
        return s_priceFeed.version();
    }

    function cheaperWithdraw() public onlyOwner {
      uint256 fundersLength = s_funders.length;
      for(uint256 funderIndex = 0; funderIndex < fundersLength; funderIndex++){
          address funder = s_funders[funderIndex]; 
          s_addressToAmountFunded[funder] = 0;
      }
      s_funders = new address[](0);
      (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
      require(callSuccess, "Transaction(call) Failed");
    }

    function withdraw() public onlyOwner {
        // for loop
        // [1, 2, 3, 4]   elements
        //  0, 1, 2, 3    index
        // for(starting index, ending index, step amount)
        for(uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++){
            address funder = s_funders[funderIndex]; 
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);

        // transfer
        // payable(msg.sender).transfer(address(this).balance);

        // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);   
        // require(sendSuccess, "Transaction(send) Failed");

        // call
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Transaction(call) Failed");
    }

    modifier onlyOwner() {
        //require(msg.sender == i_owner, "Sender is not Owner");
        if(msg.sender != i_owner) { revert FundMe__NotOwner(); }
        _;
    }

    fallback() external payable { 
        fund();
    }

    receive() external payable {
        fund();
    }

    /**
     * View/ pure functions (Getters)
     */
    function getAddressToAmountFunded(address fundingAddress) external view returns (uint256){
      return s_addressToAmountFunded[fundingAddress];
    }

    function getFunders(uint256 index) external view returns (address) {
      return s_funders[index];
    }

    function getOwner() external view returns (address) {
      return i_owner;
    }
}