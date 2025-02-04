// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        // 加载配置
        HelperConfig helperConfig = new HelperConfig();
        (address priceFeedAddress, uint256 deployerKey) = helperConfig
            .activeNetworkConfig();

        // 使用配置部署合约
        vm.startBroadcast(deployerKey);
        FundMe fundMe = new FundMe(priceFeedAddress);
        vm.stopBroadcast();

        return fundMe;
    }
}
