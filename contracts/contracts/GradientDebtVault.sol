// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// TODO likely need to fix number of shares?

import "./GradientSAVault.sol";

import "../node_modules/solmate/src/mixins/ERC4626.sol";
import "../node_modules/solmate/src/tokens/ERC20.sol"; // for DAI

import "solmate/src/utils/ReentrancyGuard.sol";

contract GradientDebtVault is ERC4626, ReentrancyGuard {

    address[] all_gradient_SA;
    mapping(address => uint256) share_value_by_SA;

    constructor(address dai) ERC4626(ERC20(dai), "Gradient Collateral", "GRADC") {}

    function registerGradientSA() {
        all_gradient_SA.push(msg.sender);
        share_value_by_SA[msg.sender] = GradientSAVault(msg.sender).value; // TODO placeholder for now
    }

    function adjustShares() {
        // TODO
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
