//SPDX-License-Identifier: MIT

// 1. Deploy mocks when we are on local anvil chain
// 2. keep track of contract address across different chain

pragma solidity ^0.8.23;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script{

  NetworkConfig public activeNetworkConfig;

  uint8 public constant DECIMALS = 8;
  int256 public constant INITIAL_PRICE = 2000e8;

  struct NetworkConfig {
    address priceFeed; // ETH/USD price feed address
  }

  constructor() {
    if (block.chainid == 11155111) {
      activeNetworkConfig = getSepholiaEthConfig();
      } else {
        activeNetworkConfig = getOrCreateAnvilEthConfig();
      }
  }

  function getSepholiaEthConfig() public pure returns(NetworkConfig memory) {
    // price feed address
    NetworkConfig memory sepholiaConfig = NetworkConfig({
      priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
    });
    return sepholiaConfig;
  }

  function getOrCreateAnvilEthConfig() public returns(NetworkConfig memory) {
    if (activeNetworkConfig.priceFeed!= address(0)) {
      return activeNetworkConfig;
    }
    // public feed address

    // 1. deploy the mocks
    // 2. return the mock address

    vm.startBroadcast();
    MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
    vm.stopBroadcast();

    NetworkConfig memory anvilConfig = NetworkConfig({
      priceFeed: address(mockPriceFeed)
    });
    return anvilConfig;
  }
}