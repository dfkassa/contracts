// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.17;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IConfigureMe.sol";
import "./IRouter.sol";

struct Payment {
    address from;
    address to;
    address token;
    uint256 amount;
    uint256 payload;
    uint256 ts;
    uint256 protocolFee;
}


interface IDFKassa {

    event NewPayment(Payment payment);

    function router() external view returns (address);
    function payments(uint256 _index) external view returns (Payment memory);
    // function userPayments(address _user, uint256 _index) external view returns (uint256);

    function pay(
        address _to,
        address _token,
        uint256 _amount,
        uint256 _payload
    ) external payable;

    function collectFees(address _reciever, uint256 _epoch) external;
}
