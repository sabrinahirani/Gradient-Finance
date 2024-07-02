// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "solmate/src/mixins/ERC4626.sol";
import "solmate/src/tokens/ERC20.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

import "solmate/src/utils/ReentrancyGuard.sol";
import "solmate/src/utils/FixedPointMathLib.sol";
import "solmate/src/auth/Owned.sol";

contract GradientCollateral is ERC4626, ReentrancyGuard {

    GradientAsset[] all;

    event GradientAssetRegistered(address indexed asset, uint256 timestamp);
    event SharesCalculated(address indexed asset, uint256 shares, uint256 timestamp);
    event Liquidated(address indexed asset, uint256 timestamp);

    constructor(address dai) ERC4626(ERC20(dai), "Gradient Collateral", "GRADC") {}

    function registerGradientAsset() public {

        // register asset
        all.push(GradientAsset(msg.sender));

        emit GradientAssetRegistered(msg.sender, block.timestamp);
    }

    function calculateShares() public {

        for (uint i = 0; i < all.length; i++) {

            // get asset
            address asset = address(all[i]);

            // liquidated if outdated
            if (all[i].timestamp() < block.timestamp - 1 days) {
                _burn(asset, ERC20(address(this)).balanceOf(asset));
                emit Liquidated(asset, block.timestamp);
                continue;
            }

            // calculate shares
            uint256 delta = all[i].delta();
            uint256 shares = ERC20(address(this)).balanceOf(asset);
            uint256 adjusted = shares * delta;

            if (delta < 1) {
                _burn(asset, shares - adjusted);
            } else if (delta > 1) {
                _mint(asset, adjusted - shares);
            }

            emit SharesCalculated(asset, adjusted, block.timestamp);
        }
    }

    /**
     * @inheritdoc ERC4626
     */
    function totalAssets() public view override returns (uint256) {
        return asset.balanceOf(address(this));
    }

    /**
     * @inheritdoc ERC4626
     */
    function beforeWithdraw(uint256 assets, uint256 shares) internal override nonReentrant {}

    /**
     * @inheritdoc ERC4626
     */
    function afterDeposit(uint256 assets, uint256 shares) internal override nonReentrant {}
}


contract GradientAsset is ERC4626, ChainlinkClient, Owned, ReentrancyGuard {

    using FixedPointMathLib for uint256;
    using Chainlink for Chainlink.Request;

    event UpdatedValue(uint256 value, uint256 timestamp);
    event Initialized(uint256 timestamp);

    uint256 public value;
    uint256 public delta;
    uint256 public timestamp;

    struct Asset {
        string ticker;
        uint256 weight;
    }
    Asset[] public underlyingAssets;

    mapping(string => uint256) underlyingAssetQty;
    mapping(string => uint256) underlyingAssetValue;
    mapping(string => uint256) underlyingAssetTimestamp;

    mapping(bytes32 => string) queryAsset;
    bool isInitialized;

    event RequestMade(bytes32 indexed requestId);
    event RequestProcessed(bytes32 indexed requestId);

    bytes32 private jobId;
    uint256 private fee;

    constructor(string memory _name, string memory _ticker, address _collateral, uint256 _value, string[] memory _tickers, uint256[] memory _weights) ERC4626 (ERC20(_collateral), _name, _ticker) Owned(msg.sender) {

        // simple error handling

        require(_value > 0, "No value");
        require(_tickers.length <= 5, "Exceeded limit on number of underlying assets");
        require(_tickers.length == _weights.length, "Failed to match assets with weights");

        // check that weights add to 100
        uint256 _sum = 0;
        for (uint256 i = 0; i < _weights.length; i++) {
            _sum += _weights[i];
        }
        require(_sum == 100, "Bad weights");

        // transfer collateral
        deposit(_value, msg.sender);

        // validate transfer
        require(ERC20(_collateral).balanceOf(address(this)) == _value, "Failed to transfer collateral");

        // set value
         value = _value;

        // set assets
        for (uint i = 0; i < _tickers.length; i++) {
            underlyingAssets.push(Asset({ticker: _tickers[i], weight: _weights[i]}));
        }

        // price oracle
        
        // reference: https://docs.chain.link/resources/link-token-contracts
        _setChainlinkToken(0x779877A7B0D9E8603169DdbD7836e478b4624789); // sepolia

        // reference: https://docs.chain.link/any-api/testnet-oracles
        _setChainlinkOracle(0x6090149792dAAeE9D1D568c9f9a6F6B46AA29eFD); // sepolia

        jobId = "7da2702f37fd48e5b1b9a5715e3509b6"; // GET > bytes

        fee = (1 * LINK_DIVISIBILITY) / 10; 

        // register gradient asset
        GradientCollateral(_collateral).registerGradientAsset();

    }

    function initialize() public returns (bool) {

        // calculate asset quantity
        for (uint256 i = 0; i < underlyingAssets.length; i++) {
            string memory _ticker = underlyingAssets[i].ticker;
            underlyingAssetQty[_ticker] = value.mulWadDown(underlyingAssets[i].weight).divWadDown(underlyingAssetValue[_ticker]);
        }

        emit Initialized(block.timestamp);
        return true;

    }

    function getAssetValue(string memory _url, string memory _ticker) public nonReentrant {
        Chainlink.Request memory request = _buildChainlinkRequest(jobId, address(this), this.setAssetValue.selector); //build request

        // api reference: https://finnhub.io/docs/api/quote
        request._add("get", _url);
        request._add("path", "c"); // get current price

        // make request
        bytes32 requestId = _sendChainlinkRequest(request, fee);
        queryAsset[requestId] = _ticker;

        emit RequestMade(requestId);
    }

    function setAssetValue(bytes32 requestId, bytes memory result) public nonReentrant recordChainlinkFulfillment(requestId)  {
        
        emit RequestProcessed(requestId);

        // get response
        underlyingAssetValue[queryAsset[requestId]] = abi.decode(result, (uint256));
        underlyingAssetTimestamp[queryAsset[requestId]] = block.timestamp;
    }

    function calculateValue() public returns (bool) {

        if (!isInitialized) {
            isInitialized = initialize();
            return true;
        }

        // calculate value
        uint256 _value;
        for (uint256 i = 0; i < underlyingAssets.length; i++) {
            string memory _ticker = underlyingAssets[i].ticker;

            // fails if outdated
            if (underlyingAssetTimestamp[_ticker] < block.timestamp - 1 days) {
                return false;
            }

            _value += underlyingAssetQty[_ticker].mulWadDown(underlyingAssetValue[_ticker]);
        }

        // calculate delta
        delta = _value.divWadDown(value);

        value = _value;
        timestamp = block.timestamp;

        emit UpdatedValue(value, timestamp);

        return true;

    }

    /**
     * @inheritdoc ERC4626
     */
    function totalAssets() public view override returns (uint256) {
        return asset.balanceOf(address(this));
    }
    
    /**
     * @inheritdoc ERC4626
     */
    function beforeWithdraw(uint256 assets, uint256 shares) internal override nonReentrant {}

    /**
     * @inheritdoc ERC4626
     */
    function afterDeposit(uint256 assets, uint256 shares) internal override nonReentrant {}

}