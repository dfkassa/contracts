// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.17;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";



contract DFK is ERC20 {

    uint256 private immutable _totalSupply = 100_000_000 ether;

    constructor() ERC20("DFKassa Token", "DFK") {
        _mint(msg.sender, _totalSupply);
    }
}
