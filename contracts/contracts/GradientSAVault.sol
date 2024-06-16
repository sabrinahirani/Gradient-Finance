// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// TODO review arithmetic + ownership

import "../node_modules/solmate/src/mixins/ERC4626.sol";
import "../node_modules/solmate/src/tokens/ERC20.sol"; // for GRADC token
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol"; // for price oracle

import "solmate/src/utils/ReentrancyGuard.sol";

contract GradientSAVault is ERC4626, ChainlinkClient, ReentrancyGuard {

    using Chainlink for Chainlink.Request;

    uint256 public value;

    struct Asset {
        string ticker;
        uint256 weight;
    }
    Asset[] public underlying_assets;

    mapping(string => uint256) underlying_asset_value;
    mapping(string => uint256) underlying_asset_qty;

    mapping(bytes32 => string) query_asset;
    bool underlying_asset_qty_is_empty;

    event RequestMade(bytes32 indexed requestId);
    event RequestProcessed(bytes32 indexed requestId);

    bytes32 private jobId;
    uint256 private fee;

    constructor(string memory _name, string memory _ticker, uint256 _value, address _collateral, address _minter, string[] memory _tickers, uint256[] memory _weights) ERC4626 (ERC20(_collateral), _name, _ticker) {

        // simple error handling

        require(_value > 0, "No value");
        require(_tickers.length <= 5, "Exceeded limit on number of underlying assets (5)");
        require(_tickers.length == _weights.length, "Failed to match assets with weights");

        // Check that weights add to 100
        uint256 _totalWeight = 0;
        for (uint256 i = 0; i < _weights.length; i++) {
            _totalWeight += _weights[i];
        }
        require(_totalWeight == 100, "Bad weights");

        // transfer collateral
        deposit(_value, _minter);

        // validate transfer
        require(ERC20(_collateral).balanceOf(address(this)) == _value, "Failed to transfer collateral");

        // set value
         value = _value;

        // price oracle
        
        // reference: https://docs.chain.link/resources/link-token-contracts
        _setChainlinkToken(0x779877A7B0D9E8603169DdbD7836e478b4624789); // sepolia

        // reference: https://docs.chain.link/any-api/testnet-oracles
        _setChainlinkOracle(0x6090149792dAAeE9D1D568c9f9a6F6B46AA29eFD); // sepolia

        jobId = "7da2702f37fd48e5b1b9a5715e3509b6"; // GET > bytes

        fee = (1 * LINK_DIVISIBILITY) / 10; 

        // set assets
        for (uint i = 0; i < _tickers.length; i++) {
            underlying_assets.push(Asset({ticker: _tickers[i], weight: _weights[i]}));
        }

    }

    function getAssetValue(string memory _url, string memory _ticker) public {
        Chainlink.Request memory request = _buildChainlinkRequest(jobId, address(this), this.fulfill.selector);

        // api reference: https://finnhub.io/docs/api/quote
        request._add("get", _url);
        request._add("path", "c");

        bytes32 requestId = _sendChainlinkRequest(request, fee);
        query_asset[requestId] = _ticker;
        emit RequestMade(requestId);
    }

    function fulfill(bytes32 requestId, bytes memory result) public recordChainlinkFulfillment(requestId) {
        emit RequestProcessed(requestId);
        underlying_asset_value[query_asset[requestId]] = abi.decode(result, (uint256));
    }

    function calculateSAValue() public returns (bool) {

        if (underlying_asset_qty_is_empty) {
            underlying_asset_qty_is_empty = !calculateQty();
            return true;
        }

        uint256 _totalValue;
        for (uint256 i = 0; i < underlying_assets.length; i++) {
            string memory _ticker = underlying_assets[i].ticker;
            _totalValue += underlying_asset_qty[_ticker] * underlying_asset_value[_ticker];
        }
        value = _totalValue;
        return true;

    }

    function calculateQty() public returns (bool) {

        for (uint256 i = 0; i < underlying_assets.length; i++) {
            string memory _ticker = underlying_assets[i].ticker;
            underlying_asset_qty[_ticker] = value*underlying_assets[i].weight / underlying_asset_value[_ticker];
        }
        return true;

    }

    /**
     * @inheritdoc ERC4626
     */
    function totalAssets() public view override returns (uint256) {
        assembly { // better safe than sorry
            if eq(sload(0), 2) {
                mstore(0x00, 0xed3ba6a6)
                revert(0x1c, 0x04)
            }
        }
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