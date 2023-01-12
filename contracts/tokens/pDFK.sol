// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.17;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../interfaces/IRouter.sol";


contract pDFK is ERC20 {

    address public router;

    constructor(
        address _router
    ) ERC20("DFKassa protocol share", "DFK") {
        _mint(msg.sender, 1);
        router = _router;
    }

    function mint(address _account, uint256 _amount) public virtual {
        IRouter _routerContract = IRouter(router);
        _routerContract.requireOwner(msg.sender);
        _mint(_account, _amount);
    }

    function burn(address _account, uint256 _amount) public virtual {
        IRouter _routerContract = IRouter(router);
        _routerContract.requireOwner(msg.sender);
        _burn(_account, _amount);
    }

}
