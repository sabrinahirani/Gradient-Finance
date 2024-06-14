// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../node_modules/solmate/src/mixins/ERC4626.sol";

contract GradientDebtVault is ERC4626 {

    constructor(address dai) ERC4626(dai, "Gradient Collateral", "GRADC") {}

    // TODO method for adjusting share based on price movements + ratios between GradientSAVault

    /**
     * @inheritdoc ERC4626
     */
    function beforeWithdraw(uint256 assets, uint256 shares) internal override nonReentrant {}

    /**
     * @inheritdoc ERC4626
     */
    function afterDeposit(uint256 assets, uint256 shares) internal override nonReentrant {}
}
