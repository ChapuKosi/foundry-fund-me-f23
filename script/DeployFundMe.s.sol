// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
  function run() external returns(FundMe) {
    // before startBroadcast -> Not a real tx
    HelperConfig helperConfig = new HelperConfig();
    address ethUsdPriceFeedAddress = helperConfig.activeNetworkConfig();
    
    // after startBroadcast -> Real tx
    vm.startBroadcast();
    //Mock
    FundMe fundMe = new FundMe(ethUsdPriceFeedAddress);
    vm.stopBroadcast();
    return fundMe;
  }
}