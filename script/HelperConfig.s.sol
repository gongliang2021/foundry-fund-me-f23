// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";

contract HelperConfig is Script {
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;
    struct NetworkConfig {
        address priceFeedAddress; // Chainlink 价格喂价地址
        uint256 deployerKey; // 部署者私钥
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        // 根据当前链 ID 加载配置
        if (block.chainid == 11155111) {
            // Sepolia 测试网
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 31337) {
            // 本地开发网络（Anvil）
            activeNetworkConfig = getAnvilEthConfig();
        } else {
            revert("Unsupported chain");
        }
    }

    // 获取 Sepolia 测试网配置
    function getSepoliaEthConfig() public view returns (NetworkConfig memory) {
        return
            NetworkConfig({
                priceFeedAddress: 0x694AA1769357215DE4FAC081bf1f309aDC325306, // Sepolia ETH/USD 价格喂价地址
                deployerKey: vm.envUint("PRIVATE_KEY") // 从环境变量加载私钥
            });
    }

    // 获取本地开发网络配置
    function getAnvilEthConfig() public returns (NetworkConfig memory) {
        vm.startBroadcast();

        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );

        vm.stopBroadcast();
        return
            NetworkConfig({
                priceFeedAddress: address(mockPriceFeed), // 本地模拟价格喂价地址
                deployerKey: vm.envUint("ANVIL_PRIVATE_KEY") // 本地开发网络可以使用默认私钥
            });
    }
}
