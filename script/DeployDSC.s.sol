//SPDX-License-Identifier:MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {DecentralizedStableCoin} from "../src/DecentralizedStableCoin.sol";
import {DSCEngine} from "../src/DSCEngine.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployDSC is Script {
    address[] public TokenAddress;
    address[] public PriceFeedAddress;

    function run()
        external
        returns (DecentralizedStableCoin, DSCEngine, HelperConfig)
    {
        HelperConfig config = new HelperConfig();
        (
            address wethUsdPriceFeed,
            address wbtcUsdPriceFeed,
            address weth,
            address wbtc,
            uint256 deployerKey
        ) = config.activateNetWorkConfig();
        TokenAddress = [weth, wbtc];
        PriceFeedAddress = [wethUsdPriceFeed, wbtcUsdPriceFeed];

        vm.startBroadcast();
        DecentralizedStableCoin dsc = new DecentralizedStableCoin();
        DSCEngine engine = new DSCEngine(
            TokenAddress,
            PriceFeedAddress,
            address(dsc)
        );
        dsc.transferOwnership(address(engine));
        vm.stopBroadcast();
        return (dsc, engine, config);
    }
}
