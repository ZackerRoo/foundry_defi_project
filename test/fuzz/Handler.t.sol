// 用来限制fuzz的范围 //比如说就我这个合约而言我会先进行抵押为了获得dsc coin但是抵押完成后我会想取会我抵押的美金或者说是以太币这是后如果没有先抵押也就不能取这就是handle作用来限制文件执行

//SPDX-License-Identifier:MIT

pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";

import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract Handle is Test {
    DSCEngine dsce;
    DecentralizedStableCoin dsc;
    ERC20Mock weth;
    ERC20Mock wbtc;
    uint256 MAX_DEPOSIT_SIZE = type(uint96).max;
    uint256 public timesMintIsCalled;
    address[] public usersWithCollateralDeposited;

    constructor(DSCEngine _dsce, DecentralizedStableCoin _dsc) {
        dsce = _dsce;
        dsc = _dsc;

        address[] memory collateralTokens = dsce.getCollateralTokens();

        weth = ERC20Mock(collateralTokens[0]);
        wbtc = ERC20Mock(collateralTokens[1]);
    }

    // mint一定是给已经有过deposited用户才有如果是新用户没有deposit无法调用mint
    function mintDsc(uint256 amount, uint256 addressSeed) public {
        // amount = bound(amount, 1, MAX_DEPOSIT_SIZE);
        if (usersWithCollateralDeposited.length == 0) return;
        address sender = usersWithCollateralDeposited[
            addressSeed % usersWithCollateralDeposited.length
        ];
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = dsce
            .getAccountInformation(sender);

        int maxDscTomint = (int256(collateralValueInUsd) / 2) -
            int256(totalDscMinted);
        if (maxDscTomint < 0) {
            return;
        }
        // timesMintIsCalled++;
        amount = bound(amount, 0, uint256(maxDscTomint));
        if (amount == 0) return;
        vm.startPrank(sender);
        dsce.mintDsc(amount);
        vm.stopPrank();
        timesMintIsCalled++;
    }

    // redeem collateral 在fuzz中所有函数的参数都是会被随机化的
    function depositCollateral(
        uint256 collateralSeed,
        uint256 amountCollateral
    ) public {
        ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);

        amountCollateral = bound(amountCollateral, 1, MAX_DEPOSIT_SIZE); //这里做了一个边界
        vm.startPrank(msg.sender);
        collateral.mint(msg.sender, amountCollateral);
        collateral.approve(address(dsce), amountCollateral); //这两部是很必要的如果没有铸币就无法用抵押物换
        dsce.depositCollateral(address(collateral), amountCollateral);
        vm.stopPrank();
        usersWithCollateralDeposited.push(msg.sender);
    }

    function redeemCollateral(
        uint256 collateralSeed,
        uint256 amountCollateral
    ) public {
        ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
        uint256 maxAmountCollateral = dsce.getCollateralBalanceOfUser(
            address(collateral),
            msg.sender
        );
        amountCollateral = bound(amountCollateral, 0, maxAmountCollateral);

        if (amountCollateral == 0) return;
        dsce.redeemCollateral(address(collateral), amountCollateral);
    }

    function _getCollateralFromSeed(
        uint256 collateralSeed
    ) private view returns (ERC20Mock) {
        if (collateralSeed % 2 == 0) {
            return weth;
        }

        return wbtc;
    }
}
