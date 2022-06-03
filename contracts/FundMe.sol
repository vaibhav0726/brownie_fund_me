// SPDX-Licence-Indentifier: MIT

pragma solidity ^0.6.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe {
    using SafeMathChainlink for uint256; //safeMath not allows for overflow

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    address public owner;
    AggregatorV3Interface public priceFeed;

    constructor(address _priceFeed) public {
        priceFeed = AggregatorV3Interface(_priceFeed); // for local ganache-cli priceFeed
        owner = msg.sender;
    }

    function fund() public payable {
        // minimum ammount of usd require to fund
        uint256 minimumUSD = 50 * 10**18; // for converting it into gwei

        require(
            getConversionRate(msg.value) >= minimumUSD,
            "you need to spend more eth"
        );
        // what the ETH -> USD conversion rate
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {
        // this aggregator priceFeed not for local ganche
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(
        //     0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
        // ); // address of where the contract is located
        return priceFeed.version();
    }

    function getPrice() public view returns (uint256) {
        // not needed for local ganache blockchain
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(
        //     0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
        // );
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return uint256(answer * 10000000000); //type casting for return the value
    }

    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice(); // in gwei
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000; // In USD
        return ethAmountInUsd;
    }

    function getEntranceFee() public view returns (uint256) {
        // minimum usd
        uint256 minimumUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        return (minimumUSD * precision) / price;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function withdraw() public payable onlyOwner {
        // only want the contract admin/owner
        // require msg.sender = owner
        msg.sender.transfer(address(this).balance);
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
    }
}
