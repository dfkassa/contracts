// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.17;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IRouter.sol";


interface ITracker {
    function router() external view returns (address);

    function vmPointsLatestEpoch() external view returns (uint256);
    function vPointsUserAmount(uint256 _epoch, address _user) external view returns (uint256);
    function mPointsUserAmount(uint256 _epoch, address _user) external view returns (uint256);
    function userAvailableFees(uint256 _epoch, address _user) external view returns (uint256);

    function totalVPoints(uint256 _epoch) external view returns (uint256);
    function totalMPoints(uint256 _epoch) external view returns (uint256);

    function totalCollectedFees(uint256 _epoch) external view returns (uint256);

    // Internal fn
    function mintVPoints(address _user, uint256 _amount) external;
    function mintMPoints(address _user, uint256 _amount) external;
    function increaseTotalCollectedFees(uint256 _amount) external;

}
