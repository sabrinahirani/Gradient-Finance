// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../node_modules/solmate/src/tokens/ERC20.sol";

contract GradientLP {

    ERC20 immutable x; // token x
    ERC20 immutable y; // token y

    constructor(address _x, address _y) {
        x = ERC20(_x);
        y = ERC20(_y);
    }

}

contract GradientDEX {

}