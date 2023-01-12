// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.17;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/ITreasury.sol";
import "./ConfigureMe.sol";


contract Treasury is ITreasury {
    address public router;
    mapping(address => Stake) private __userStake;

    uint256 public totalStakedAmount;
    uint256 public totalStakersCount;

    constructor(address _router) {
        router = _router;
    }

    function stakeDFK(uint256 _amount) external {
        Stake memory _currentStake = __userStake[msg.sender];

        IRouter _routerContract = IRouter(router);
        IConfigureMe _config = IConfigureMe(_routerContract.config());
        IERC20 _erc20Contract = IERC20(_routerContract.dfk());

        _erc20Contract.transferFrom(msg.sender, address(this), _amount);

        if (_currentStake.amount == 0) {
            _currentStake.snapshotTime = block.timestamp;
            _currentStake.startTime = block.timestamp;
            totalStakersCount += 1;
        } else {
            _currentStake.mpSnapshotedAmount +=
                _config.dfkStakingMP_APR_X3()
                * (block.timestamp - _currentStake.snapshotTime)
                * _currentStake.amount
                / 365 days / 1000;
            _currentStake.snapshotTime = block.timestamp;
        }
        totalStakedAmount += _amount;
        _currentStake.amount += _amount;
    }

    function unstakeDFK(uint256 _amount) external {
        Stake memory _currentStake = __userStake[msg.sender];
        require(
            _currentStake.amount >= _amount,
            "Cannot unstake more than you have"
        );

        IRouter _routerContract = IRouter(router);
        IConfigureMe _config = IConfigureMe(_routerContract.config());
        IERC20 _erc20Contract = IERC20(_routerContract.dfk());

        _currentStake.mpSnapshotedAmount +=
            _config.dfkStakingMP_APR_X3()
            * _currentStake.amount
            * (block.timestamp - _currentStake.snapshotTime)
            / 365 days / 1000;
        _currentStake.snapshotTime = block.timestamp;
        _currentStake.mpSnapshotedAmount -=
            (_amount / _currentStake.amount) *
            _currentStake.mpSnapshotedAmount;
        _currentStake.amount -= _amount;
        totalStakedAmount -= _amount;

        if (_currentStake.amount == 0)
            totalStakersCount -= 1;

        _erc20Contract.transferFrom(msg.sender, address(this), _amount);
    }

    function userCurrentMP(address _user) external view virtual override returns (uint256) {
        Stake memory currentStake = __userStake[_user];

        IRouter _routerContract = IRouter(router);
        IConfigureMe _config = IConfigureMe(_routerContract.config());

        return _config.dfkStakingMP_APR_X3()
            * currentStake.amount
            * (block.timestamp - currentStake.snapshotTime)
            / 365 days / 1000;
    }

    function userStake(address _user) external view returns (Stake memory) {
        return __userStake[_user];
    }

    function userExtraVMDFK(address _user) external view virtual override returns (uint256) {
        Stake memory _currentStake = __userStake[_user];

        IRouter _routerContract = IRouter(router);
        IConfigureMe _config = IConfigureMe(_routerContract.config());

        return (_currentStake.amount + this.userCurrentMP(_user))
            * 1 ether
            / (
                (totalStakedAmount == 0 ? 1 : totalStakedAmount)
                / (totalStakersCount == 0 ? 1 : totalStakersCount)
            )
            * _config.dfkStakingVMDFKImpactX3()
        ;

    }

    function withdraw(address _user, uint256 _amount) external virtual override {
        IRouter _routerContract = IRouter(router);
        require(msg.sender == _routerContract.dfkassa(), "Accessible only from DFKassa contract");
        payable(address(_user)).transfer(_amount);
    }

}
