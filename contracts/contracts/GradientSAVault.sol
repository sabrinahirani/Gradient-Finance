// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../node_modules/solmate/src/mixins/ERC4626.sol";

import "../node_modules/solmate/src/tokens/ERC20.sol"; // for GRADC token
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol"; // for price oracle

contract GradientSAVault is ERC4626 {

    uint256 public value;

    ERC20 public collateral;
    address public oracle;

    struct Asset {
        string name;
        uint256 weight;
        uint256 amount;
    }

    Asset[] public assets;

    constructor(string memory _name, string memory _ticker, uint256 _value, address _collateral, address _oracle, address _minter, string[] memory _assets, uint[] memory _weights) ERC4626 (_collateral, _name, _ticker) {
        
        // TODO add error handling
        // ^ ensure proper assets + weights

        value = _value;
        
        collateral = ERC20(_collateral)
        oracle = _oracle; // TODO figure out oracle

        collateral.transferFrom(_minter, address payable(this), value);

        // TODO add error handling - ensure that balance is updated (or revert)

        for (uint i = 0; i < _assets.length; i++) {
            assets.push(Asset({name: _assets[i], weight: _weights[i], amount: _weights[i]*value})); // TODO find an arithmetic library for safe math?
        }

    }

    // TODO use price feed to update value of vault according to price movements of underlying assets
    
    /**
     * @inheritdoc ERC4626
     */
    function beforeWithdraw(uint256 assets, uint256 shares) internal override nonReentrant {}

    /**
     * @inheritdoc ERC4626
     */
    function afterDeposit(uint256 assets, uint256 shares) internal override nonReentrant {}

}