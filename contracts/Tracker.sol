// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.17;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/ITracker.sol";
import "./interfaces/IConfigureMe.sol";
import "./tokens/pDFK.sol";


contract Tracker is ITracker {

    address public router;

    uint256 public vmPointsLatestEpoch;
    uint256 private __currentlyPassedEpochDueDuration;

    mapping(uint256 => mapping(address => uint256)) public vPointsUserAmount;
    mapping(uint256 => mapping(address => uint256)) public mPointsUserAmount;
    mapping(uint256 => uint256) public totalCollectedFees;

    mapping(uint256 => uint256) public totalVPoints;
    mapping(uint256 => uint256) public totalMPoints;

    mapping(uint256 => mapping(address => bool)) private __userAvailableWithdraw;

    constructor(address _router) {
        router = _router;
    }

    function _upgetLatestEpoch() private returns (uint256 latestEpoch) {
        IRouter _routerContract = IRouter(router);
        IConfigureMe _config = IConfigureMe(_routerContract.config());

        latestEpoch =
            (block.timestamp + _config.epochRecalculationShift())
            / _config.epochRecalculationMod();

        if (latestEpoch != __currentlyPassedEpochDueDuration) {
            __currentlyPassedEpochDueDuration = latestEpoch;
            vmPointsLatestEpoch += 1;
        }
    }

    function mintVPoints(address _user, uint256 _amount) external virtual override onlyDFKassaAccessible {
        uint256 _latestEpoch = _upgetLatestEpoch();
        vPointsUserAmount[_latestEpoch][_user] += _amount;
        totalVPoints[_latestEpoch] += _amount;
    }

    function mintMPoints(address _user, uint256 _amount) external virtual override onlyDFKassaAccessible {
        uint256 _latestEpoch = _upgetLatestEpoch();
        mPointsUserAmount[_latestEpoch][_user] += _amount;
        totalMPoints[_latestEpoch] += _amount;
    }

    function increaseTotalCollectedFees(uint256 _amount) external virtual override onlyDFKassaAccessible {
        uint256 _latestEpoch = _upgetLatestEpoch();
        totalCollectedFees[_latestEpoch] += _amount;
    }

    function userAvailableFees(uint256 _epoch, address _user) external view returns (uint256) {
        if (!__userAvailableWithdraw[_epoch][_user]) {
            return 0;
        }

        IRouter _routerContract = IRouter(router);
        IConfigureMe _config = IConfigureMe(_routerContract.config());
        pDFK _pdfk = pDFK(_routerContract.pdfk());

        uint256 _totalCollectedFees = totalCollectedFees[_epoch];

        FeesShare memory _currentFeesShare = _config.currentFeesShareX18();
        uint256 visitorFees = _totalCollectedFees * _currentFeesShare.visitor / 1 ether;
        uint256 merchantFees = _totalCollectedFees * _currentFeesShare.merchant / 1 ether;
        uint256 protocolFees = _totalCollectedFees * _currentFeesShare.protocol / 1 ether;

        uint256 vDFKFeesShareX18 = 1 ether * vPointsUserAmount[_epoch][_user] / totalVPoints[_epoch];
        uint256 mDFKFeesShareX18 = 1 ether * mPointsUserAmount[_epoch][_user] / totalMPoints[_epoch];
        uint256 pDFKFeesShareX18 = 1 ether * _pdfk.balanceOf(_user) / _pdfk.totalSupply();

        return (
            visitorFees * vDFKFeesShareX18 / 1 ether
            + merchantFees * mDFKFeesShareX18 / 1 ether
            + protocolFees * pDFKFeesShareX18 / 1 ether
        );

    }

    modifier onlyDFKassaAccessible {
        IRouter _routerContract = IRouter(router);
        require(msg.sender == _routerContract.dfkassa(), "Accessible only from DFKassa contract");
        _;
    }

}
