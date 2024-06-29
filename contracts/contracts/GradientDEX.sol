// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "solmate/src/tokens/ERC20.sol";
import "solmate/src/utils/FixedPointMathLib.sol";

contract LiquidityRewardPool {

    using FixedPointMathLib for uint256;

    ERC20 immutable dai;
    LiquidityPool immutable accounting;

    uint256 timestamp;
    uint256 delay = 5 days;

    constructor(address _dai, address _accounting) {
        dai = ERC20(_dai);
        accounting = LiquidityPool(_accounting);
        timestamp = block.timestamp;
    }

    function distribute() public {

        require(block.timestamp > timestamp + delay, "Too early");

        uint256 _totalReward = dai.balanceOf(address(this));
        address[] providers = accounting.providers();
        mapping (address => bool) memory rewarded;

        for (uint256 i = 0; i < providers.length; i++) {
            if (rewarded[providers[i]] == false) {
                uint256 _reward = _totalReward.mulWadDown(accounting.balanceOf(msg.sender)).divWadDown(accounting.totalSupply());
                dai.transfer(providers[i], _reward);
            }
        }
    }
    
}

contract LiquidityPool is ERC20 {

    using FixedPointMathLib for uint256;

    ERC20 immutable x; // gradient asset
    ERC20 immutable y; // dai

    address immutable reward; // reward pool
    address immutable dai;

    uint256 public FEE = 1;

    address[] public providers;

    constructor(address _x, address _y, uint256 _amountX, uint256 _amountY, address provider) ERC20("Gradient Liquidity Token", "GRADL", 18) {
        x = ERC20(_x);
        y = ERC20(_y);

        x.transferFrom(msg.sender, address(this), _amountX);
        y.transferFrom(msg.sender, address(this), _amountY);
        _mint(msg.sender, _amountY +  XToY(_amountX));
        providers.append(provider);

        reward = address(new LiquidityRewardPool(_y, address(this)));
        dai = ERC20(_y);
    }

    function depositX(uint256 _amountX) public {
        x.transferFrom(msg.sender, address(this), _amountX);
        uint _amountY = XToY(_amountX);
        if (balanceOf(msg.sender) == 0) {
            providers.append(msg.sender);
        }
        _mint(msg.sender, _amountY);
    }

    function depositY(uint256 _amountY) public {
        y.transferFrom(msg.sender, address(this), _amountY);
        if (balanceOf(msg.sender) == 0) {
            providers.append(msg.sender);
        }
        _mint(msg.sender, _amountY);
    }

    function withdrawX(uint256 _amountX) public {
        if (XToY(balanceOf(msg.sender)) < _amountX) {
            _amountX = XToY(balanceOf(msg.sender));
        }
        x.transfer(msg.sender, _amountX);
        _burn(msg.sender, _amountX);
    }

    function withdrawY(uint256 _amountY) public {
        if (balanceOf(msg.sender) < _amountY) {
            _amountY = balanceOf(msg.sender);
        }
        y.transfer(msg.sender, _amountY);
        _burn(msg.sender, _amountY);
    }

    function tradeXToY(uint256 _amountX) public {

        dai.transferFrom(msg.sender, address(reward), FEE);

        x.transferFrom(msg.sender, address(this), _amountX);
        uint256 _amountY = YToX(_amountX);
        y.transfer(msg.sender, _amountY);

    }

    function tradeYToX(uint256 _amountY) public {

        dai.transferFrom(msg.sender, address(reward), FEE);

        y.transferFrom(msg.sender, address(this), _amountY);
        uint256 _amountX = XToY(_amountY);
        x.transfer(msg.sender, _amountX);
    }

    function XToY(uint256 _amountX) public returns (uint256) {
        return _amountX.mulWadDown(y.balanceOf(address(this))).divWadDown(x.balanceOf(address(this)));
    }

    function YToX(uint256 _amountY) public returns (uint256) {
        return _amountY.mulWadDown(x.balanceOf(address(this))).divWadDown(y.balanceOf(address(this)));
    }

}

contract GradientDEX {

    address[] public pools;

    function registerLiquidityPool(address _x, address _y, uint256 _amountX, uint256 _amountY) {
        LiquidityPool lp = new LiquidityPool(_x, _y, _amountX, _amountY, msg.sender);
        pools.append(address(lp));
    }

}