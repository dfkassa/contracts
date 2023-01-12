// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.17;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IRouter.sol";


struct Stake {
    uint256 amount;
    uint256 startTime;
    uint256 snapshotTime;
    uint256 mpSnapshotedAmount;
}


interface ITreasury {
    // State
    function router() external view returns (address);
    function userStake(address _user) external view returns (Stake memory);
    function userCurrentMP(address _user) external view returns (uint256);
    function totalStakersCount() external view returns (uint256);
    function totalStakedAmount() external view returns (uint256);

    function userExtraVMDFK(address _user) external view returns (uint256);

    // Internal
    function withdraw(address _user, uint256 amount) external;

    // Public fn
    function stakeDFK(uint256 _amount) external;
    function unstakeDFK(uint256 _amount) external;

}
