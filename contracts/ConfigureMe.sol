// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.17;

import "./interfaces/IConfigureMe.sol";


contract ConfigureMe is IConfigureMe {

    uint256 public visitorTxGasFee = 21000;

    FeesShare public _oldFeesShareX18 = FeesShare(35 ether, 35 ether, 20 ether);
    FeesShare public _newFeesShareX18 = FeesShare(35 ether, 35 ether, 20 ether);
    MathFunction public feesShareChangingCourse = MathFunction.LINEAR;
    uint256 public feesShareChangingDuration = 0;
    uint256 public feesShareChangingStartTime = 0;

    uint256 public epochRecalculationMod = 86400 * 7;
    uint256 public epochRecalculationShift = 0;

    uint256 public dfkPaymentExtraVDFKPoints = 2 ether;
    uint256 public dfkPaymentFeesDiscount = 10500;
    uint256 public dfkReceivingExtraMDFKPoints = 2 ether;

    uint256 public dfkStakingVMDFKImpactX3 = 2_000;
    uint256 public dfkStakingMP_APR_X3 = 1_000;


    function oldFeesShareX18() external view returns (FeesShare memory) {
        return _oldFeesShareX18;
    }

    function newFeesShareX18() external view returns (FeesShare memory) {
        return _newFeesShareX18;
    }

    function currentFeesShareX18() external view returns (FeesShare memory) {
        uint256 _timeDeltaTotal = feesShareChangingDuration - feesShareChangingStartTime;
        uint256 _timeDeltaPassed = block.timestamp - feesShareChangingStartTime;
        uint256 _timePassedInPercentsX16 = _timeDeltaPassed * 1 ether / _timeDeltaTotal;

        uint256 _feesSharePassedInPercentsX16;
        if (feesShareChangingCourse == MathFunction.LINEAR) {
            _feesSharePassedInPercentsX16 = _timePassedInPercentsX16;
        } else {
            assert(false);
        }

        FeesShare memory _currentFeesShare = FeesShare({
            merchant: __calcNewShareForMember(
                _oldFeesShareX18.merchant, _newFeesShareX18.merchant, _timePassedInPercentsX16
            ),
            visitor: __calcNewShareForMember(
                _oldFeesShareX18.visitor, _newFeesShareX18.visitor, _timePassedInPercentsX16
            ),
            protocol: __calcNewShareForMember(
                _oldFeesShareX18.protocol, _newFeesShareX18.protocol, _timePassedInPercentsX16
            )
        });
        return _currentFeesShare;
    }

    function __calcNewShareForMember(
        uint _old,
        uint256 _new,
        uint256 _timePassedInPercentsX16
    ) private pure returns (uint256) {
        uint256 diff = _old > _new ? _old - _new : _new - _old;
        return diff * _timePassedInPercentsX16 / 1 ether;
    }

}
