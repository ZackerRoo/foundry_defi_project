// SPDX-License-Identifier: MIT

// 不变性测 试

// 1. The total supply of DSC should be less than the total value of collateral
// 2. Getter view function should never revert evergreen invariant：持久不变性

pragma solidity ^0.8.19;
import {Test, console} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Handle} from "./Handler.t.sol";

contract InvariantsTest is StdInvariant, Test {
    DeployDSC deployer;
    DSCEngine dsce;
    DecentralizedStableCoin dsc;
    HelperConfig config;
    address weth;
    address wbtc;
    Handle handle;

    function setUp() public {
        deployer = new DeployDSC();
        (dsc, dsce, config) = deployer.run();
        (, , weth, wbtc, ) = config.activateNetWorkConfig();
        // targetContract(address(dsce));
        handle = new Handle(dsce, dsc);
        targetContract(address(handle));
    }

    function invariant_protpcolMustHaveMoreValueThanTotalSupply() public {
        // get value of all collateral in the protocol
        // compare it to all the debt (dsc)

        uint256 totalSupply = dsc.totalSupply();

        uint256 totalWethDeposited = IERC20(weth).balanceOf(address(dsce));
        uint256 totalWbtcDeposited = IERC20(wbtc).balanceOf(address(dsce));

        uint256 wethValue = dsce.getUsdValue(weth, totalWethDeposited);
        uint256 wbtcValue = dsce.getUsdValue(wbtc, totalWbtcDeposited);

        console.log("weth", wethValue);
        console.log("wbtc", wbtcValue);
        console.log("total Supply", totalSupply);
        console.log("timesMintIsCalled", handle.timesMintIsCalled());

        assert(wethValue + wbtcValue >= totalSupply);
    }
}
