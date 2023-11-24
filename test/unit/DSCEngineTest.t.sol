//SPDX-License-Identifier:MIT

pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract DSCEngineTest is Test {
    HelperConfig config;
    DeployDSC deployer;
    DSCEngine dsce;
    DecentralizedStableCoin dsc;
    address wethUsdPriceFeed;
    address wbtcUsdPriceFeed;
    address weth;

    address public USER = makeAddr("user");
    uint256 public constant AMOUNT_COLLATERAL = 10 ether;
    uint256 public constant USER_STARTERC20_BALANCE = 10 ether;

    function setUp() public {
        deployer = new DeployDSC();
        (dsc, dsce, config) = deployer.run();
        (wethUsdPriceFeed, wbtcUsdPriceFeed, weth, , ) = config
            .activateNetWorkConfig();
        ERC20Mock(weth).mint(USER, USER_STARTERC20_BALANCE);
    }

    function testGetUsdValue() public {
        uint256 ethAmount = 15e18;
        uint256 expectedUsd = 30000e18;
        uint256 acutualUsd = dsce.getUsdValue(weth, ethAmount);
        assertEq(expectedUsd, acutualUsd);
    }

    function testRevertsIfCollateralZero() public {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(dsce), AMOUNT_COLLATERAL);

        vm.expectRevert(DSCEngine.DSCEngine__NeedMoreThanZero.selector);
        dsce.depositCollateral(weth, 0);
        vm.stopPrank();
    }

    address[] tokenAddress;
    address[] priceFeedAddresses;

    function testRevertsIfTokenLengthDoesntMatchPriceFeeds() public {
        tokenAddress.push(weth);
        priceFeedAddresses.push(wethUsdPriceFeed);
        priceFeedAddresses.push(wbtcUsdPriceFeed);

        vm.expectRevert(
            DSCEngine
                .DSCEngine__tokenAddressAndpriceFeedAddressMustbeequal
                .selector
        );
        new DSCEngine(tokenAddress, priceFeedAddresses, address(dsc));
    }

    function testGetTokenAmountFromUsd() public {
        uint256 usdAmount = 100 ether;
        uint256 expectWeth = 0.05 ether;

        uint256 actualWeth = dsce.getTokenAmountFromUsd(weth, usdAmount);
        assertEq(expectWeth, actualWeth);
    }

    function testRevertsWithUnapprovedCollateral() public {
        ERC20Mock ranToken = new ERC20Mock();
        // assertEq(uint160(address(ranToken)), 0);
        vm.startPrank(USER);
        vm.expectRevert(
            DSCEngine.DSCEngine__priceFeedAddressMoreThanZero.selector
        );
        // 一定过不了因为dsce构造函数只有两种币 这里新建一个不会加入到已经构建完成的dsce中
        dsce.depositCollateral(address(ranToken), AMOUNT_COLLATERAL);
        vm.stopPrank();
    }

    modifier depositCollateral() {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(dsce), AMOUNT_COLLATERAL); // 这个表示个dsce 可以存入AMOUNT_COLLATERAL 的weth的代币
        dsce.depositCollateral(weth, AMOUNT_COLLATERAL);
        vm.stopPrank();
        _;
    }

    function testCanDepositCollateralAndGetAccountInfo()
        public
        depositCollateral
    {
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = dsce
            .getAccountInformation(USER);

        uint256 expectTotalDscMinted = 0;
        uint256 expectedCollaterAmount = dsce.getTokenAmountFromUsd(
            weth,
            collateralValueInUsd
        );
        assertEq(expectTotalDscMinted, totalDscMinted);

        // 10,000000000000000000
        // 20000,000000000000000000
        //assertEq(expectedCollaterValueInUsd, collateralValueInUsd);//这个是错误的
        assertEq(expectedCollaterAmount, AMOUNT_COLLATERAL);
    }
}
