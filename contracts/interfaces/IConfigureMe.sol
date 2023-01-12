// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.17;

enum MathFunction {
    LINEAR,
    SIGMOID,
    SQUARTED,
    NEGATIVE_SQUARTED
}

struct FeesShare {
    uint256 merchant;
    uint256 visitor;
    uint256 protocol;
}


interface IConfigureMe {
    function visitorTxGasFee() external view returns (uint256);

    function oldFeesShareX18() external view returns (FeesShare memory);
    function newFeesShareX18() external view returns (FeesShare memory);
    function feesShareChangingCourse() external view returns (MathFunction);
    function feesShareChangingDuration() external view returns (uint256);
    function feesShareChangingStartTime() external view returns (uint256);

    // Every `portion_recalculation_mod` time + shist
    // mDFK and vDFK are distributed between participants
    // according to their activities
    function epochRecalculationMod() external view returns (uint256);
    function epochRecalculationShift() external view returns (uint256);

    // Pay/receivie DFK and get more vDFK/mDFK
    function dfkPaymentExtraVDFKPoints() external view returns (uint256);
    function dfkPaymentFeesDiscount() external view returns (uint256);
    function dfkReceivingExtraMDFKPoints() external view returns (uint256);

    // Staking benifits
    //
    // Additional vDFK/mDFK multiplier =\
    // staking_points * staking_vmdfk_impact
    // where:
    // staking_points: (user_staked / avarage_stake_amount) > 1 ? this : 0) * user_mp
    // user_staked: how much he staked
    // avarage_stake_amount: avarage around all stakes
    // user_mp = collected_mp + unclaimed_mp (unclaimed_mp = (now - last_mp_collection_ts) / (86400*365) * mp_apr)
    // dfk_staking_vmdfk_impact: how much staking are rewarded at all
    // dfk_staking_mp_apr: how much long term staking are rewarded
    function dfkStakingVMDFKImpactX3() external view returns (uint256);
    function dfkStakingMP_APR_X3() external view returns (uint256);

    function currentFeesShareX18() external view returns (FeesShare memory);
}
