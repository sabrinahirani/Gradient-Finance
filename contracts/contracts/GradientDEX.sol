// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "solmate/src/tokens/ERC20.sol";
import "solmate/src/utils/FixedPointMathLib.sol";
import "solmate/src/utils/ReentrancyGuard.sol";

contract LiquidityRewardPool is ReentrancyGuard {

    using FixedPointMathLib for uint256;

    ERC20 immutable reward;
    LiquidityPool immutable accounting;

    uint256 public timestamp;

    uint256 public delay = 7 days;

    constructor(address _reward, address _accounting) {
        reward = ERC20(_reward);
        accounting = LiquidityPool(_accounting);
        timestamp = block.timestamp;
    }

    function distribute() public nonReentrant {

        require(block.timestamp > timestamp + delay, "Too early");

        uint256 _total = reward.balanceOf(address(this));
        address[] memory _providers = accounting.getProviders();

        require(_total > _providers.length, "Not enough reward");

        for (uint256 i = 0; i < _providers.length; i++) {
            address _provider = _providers[i];
            uint256 _amount = _total.mulWadDown(accounting.balanceOf(msg.sender)).divWadDown(accounting.totalSupply());
            reward.transfer(_provider, _amount);
        }

        timestamp = block.timestamp;

    }


}

contract LiquidityPool is ERC20, ReentrancyGuard {

    using FixedPointMathLib for uint256;

    ERC20 immutable x; // gradient asset
    ERC20 immutable y; // dai
    ERC20 immutable dai;

    address immutable reward; // reward pool

    address[] public providers;

    uint256 public FEE = 1;

    constructor(address _x, address _y, uint256 _amountX, uint256 _amountY, address provider) ERC20("Gradient Liquidity Token", "GRADL", 18) {
        x = ERC20(_x);
        y = ERC20(_y);

        x.transferFrom(msg.sender, address(this), _amountX);
        y.transferFrom(msg.sender, address(this), _amountY);
        _mint(msg.sender, _amountY +  XToY(_amountX));
        providers.push(provider);

        reward = address(new LiquidityRewardPool(_y, address(this)));
        dai = ERC20(_y);
    }

    function depositX(uint256 _amountX) public nonReentrant {
        x.transferFrom(msg.sender, address(this), _amountX);
        uint _amountY = XToY(_amountX);
        if (ERC20(this).balanceOf(msg.sender) == 0) {
            providers.push(msg.sender);
        }
        _mint(msg.sender, _amountY);
    }

    function depositY(uint256 _amountY) public nonReentrant {
        y.transferFrom(msg.sender, address(this), _amountY);
        if (ERC20(this).balanceOf(msg.sender) == 0) {
            providers.push(msg.sender);
        }
        _mint(msg.sender, _amountY);
    }

    function withdrawX(uint256 _amountX) public nonReentrant {
        if (XToY(ERC20(this).balanceOf(msg.sender)) < _amountX) {
            _amountX = XToY(ERC20(this).balanceOf(msg.sender));
        }
        x.transfer(msg.sender, _amountX);
        _burn(msg.sender, _amountX);
    }

    function withdrawY(uint256 _amountY) public nonReentrant {
        if (ERC20(this).balanceOf(msg.sender) < _amountY) {
            _amountY = ERC20(this).balanceOf(msg.sender);
        }
        y.transfer(msg.sender, _amountY);
        _burn(msg.sender, _amountY);
    }

    function tradeXToY(uint256 _amountX) public nonReentrant {

        dai.transferFrom(msg.sender, address(reward), FEE);

        x.transferFrom(msg.sender, address(this), _amountX);
        uint256 _amountY = YToX(_amountX);
        y.transfer(msg.sender, _amountY);

    }

    function tradeYToX(uint256 _amountY) public nonReentrant {

        dai.transferFrom(msg.sender, address(reward), FEE);

        y.transferFrom(msg.sender, address(this), _amountY);
        uint256 _amountX = XToY(_amountY);
        x.transfer(msg.sender, _amountX);
    }

    function XToY(uint256 _amountX) public view returns (uint256) {
        return _amountX.mulWadDown(y.balanceOf(address(this))).divWadDown(x.balanceOf(address(this)));
    }

    function YToX(uint256 _amountY) public view returns (uint256) {
        return _amountY.mulWadDown(x.balanceOf(address(this))).divWadDown(y.balanceOf(address(this)));
    }

    function getProviders() public view returns (address[] memory) { // Added function to fetch providers
        return providers;
    }

}

contract GradientDEX {

    address[] public pools;

    function registerLiquidityPool(address _x, address _y, uint256 _amountX, uint256 _amountY) public {
        LiquidityPool lp = new LiquidityPool(_x, _y, _amountX, _amountY, msg.sender);
        pools.push(address(lp));
    }

}