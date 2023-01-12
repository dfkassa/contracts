// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.17;

import "./interfaces/IRouter.sol";


contract RouterV1 is IRouter {

    address public dfk;
    address public mdfk;
    address public vdfk;
    address public pdfk;

    address public dfkassa;
    address public config;
    address public treasury;
    address public tracker;

    address public owner;

    bool private __initialized;

    function init(
        address _dfk,
        address _mdfk,
        address _vdfk,
        address _pdfk,

        address _dfkassa,
        address _config,
        address _treasury,
        address _tracker
    ) public virtual {
        require(!__initialized, "Cannot initilize twice");

        dfk = _dfk;
        mdfk = _mdfk;
        vdfk = _vdfk;
        pdfk = _pdfk;

        dfkassa = _dfkassa;
        config = _config;
        treasury = _treasury;
        tracker = _tracker;

        owner = msg.sender;

        __initialized = true;
    }

    function VERSION() external pure returns (uint32) {
        return 1;
    }

    function requireOwner(address _user) external view virtual override {
        require(_user == owner, "Accessible only for owners");
    }
}
