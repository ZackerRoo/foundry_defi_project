// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * @title OracleLib
 * @author zhenkun luo
 * @notice this library is used to check the chainlink Oracle for stale data
 * if price stale the function will revert and render the DSCEnigne unusable this is we want to DSCEngine to freeze if prices become stale
 *
 * so if ther chainlink network explodes and you have a lot og meney locjed in protocol
 */

library OracleLib {
    error Oracle__StalePrice();
    uint256 private constant TIMEOUT = 3 hours;

    function staleCheckLastestRoundData(
        AggregatorV3Interface priceFeed
    ) public view returns (uint80, int256, uint256, uint256, uint80) {
        (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        uint256 secondsSince = block.timestamp - updatedAt;
        if (secondsSince > TIMEOUT) {
            revert Oracle__StalePrice();
        }
        return (roundId, answer, startedAt, updatedAt, answeredInRound);
    }
}
