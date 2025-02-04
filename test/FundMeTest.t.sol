// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {PriceConverter} from "../src/PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");

    using PriceConverter for uint256;

    function setUp() public {
        // 部署合约
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, 20 ether); // 给 `user` 地址分配 20 ether
    }

    function testMinmunDollarIsFive() public view {
        vm.assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        // 获取配置
        HelperConfig helperConfig = new HelperConfig();
        (, uint256 deployerKey) = helperConfig.activeNetworkConfig();
        address deployerAddress = vm.addr(deployerKey); // 通过私钥获取地址

        // 部署合约
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();

        // 打印日志
        console.log("Deployer Address:", deployerAddress);
        console.log("FundMe Owner:", fundMe.i_owner());

        // 断言
        assertEq(fundMe.i_owner(), deployerAddress, "Owner is not correct");
    }

    function testPriceFeedVersionIsAccurate() public view {
        // 获取 Chainlink 价格喂价合约的版本号
        uint256 version = fundMe.getVersion();

        // 打印日志
        console.log("Price Feed Version:", version);

        // 断言版本号大于 0
        assertGt(version, 0);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.fund{value: 0.0023 ether}();
    }

    function testFundUpdatesFundedDataStructure() public {
        // 获取价格喂价合约
        AggregatorV3Interface priceFeed = fundMe.s_friceFeed();

        // 计算转换率
        uint256 conversionRate = uint256(10 ether).getConversionRate(priceFeed);

        // 模拟用户进行资助
        vm.prank(USER);
        fundMe.fund{value: 10 ether}();

        // 检查数据结构是否更新
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, 10 ether);

        // 检查转换率（可选，具体取决于测试要求）
        assertGt(conversionRate, 0);
    }
}
