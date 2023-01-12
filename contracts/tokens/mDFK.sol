// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.17;


import "../interfaces/ITracker.sol";
import "../interfaces/IRouter.sol";

contract mDFK {

    address public router;

    string public symbol = "mDFK";
    string public name = "Merchants DFKassa rewards token";
    uint8 public immutable decimals = 18;

    constructor(address _router){
        router = _router;
    }

    function totalSupply() public view virtual returns (uint256) {
        IRouter _routerContract = IRouter(router);
        ITracker _trackerContract = ITracker(_routerContract.tracker());

        return _trackerContract.totalMPoints(_trackerContract.vmPointsLatestEpoch());
    }

    function balanceOf(address _account) public view virtual returns (uint256) {
        IRouter _routerContract = IRouter(router);
        ITracker _trackerContract = ITracker(_routerContract.tracker());

        uint256 _latestEpoch = _trackerContract.vmPointsLatestEpoch();
        return (
            _trackerContract.mPointsUserAmount(_latestEpoch, _account)
            / _trackerContract.totalMPoints(_latestEpoch)
        );
    }
}
