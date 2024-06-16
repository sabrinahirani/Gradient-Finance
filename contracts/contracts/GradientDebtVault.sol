// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// TODO revise

import "./GradientSAVault.sol";

import "../node_modules/solmate/src/mixins/ERC4626.sol";
import "../node_modules/solmate/src/tokens/ERC20.sol"; // for DAI

import "solmate/src/utils/ReentrancyGuard.sol";

contract GradientDebtVault is ERC4626, ReentrancyGuard {

    GradientSAVault[] SA;
    mapping(address => int256) change_in_balance;

    constructor(address dai) ERC4626(ERC20(dai), "Gradient Collateral", "GRADC") {}

    function registerGradientSA() public {
        SA.push(GradientSAVault(msg.sender));
    }

    function adjustShares() public {
        for (uint i = 0; i < SA.length; i++) {

            address vault = address(SA[i]);

            uint256 delta = SA[i].delta();
            uint256 currentBalance = ERC20(address(this)).balanceOf(address(SA[i]));
            uint256 adjustedBalance = currentBalance * delta;

            if (delta < 1) {
                _burn(vault, currentBalance - adjustedBalance);
            } else if (delta > 1) {
                _mint(vault, adjustedBalance - currentBalance);
            }
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
