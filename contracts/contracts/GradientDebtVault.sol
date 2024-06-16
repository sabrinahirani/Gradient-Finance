// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../node_modules/solmate/src/mixins/ERC4626.sol";
import "../node_modules/solmate/src/tokens/ERC20.sol"; // for DAI
import "solmate/src/utils/ReentrancyGuard.sol";

contract GradientDebtVault is ERC4626, ReentrancyGuard {

    constructor(address dai) ERC4626(ERC20(dai), "Gradient Collateral", "GRADC") {}

    // TODO method for adjusting share based on price movements + ratios between GradientSAVault

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
