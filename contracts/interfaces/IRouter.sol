// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.17;


interface IRouter {
    function VERSION() external pure returns (uint32);

    function dfk() external view returns (address);
    function mdfk() external view returns (address);
    function vdfk() external view returns (address);
    function pdfk() external view returns (address);

    function dfkassa() external view returns (address);
    function config() external view returns (address);
    function treasury() external view returns (address);
    function tracker() external view returns (address);

    function requireOwner(address _user) external view;
}
