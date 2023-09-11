// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CurrencyToken is ERC20 {
    constructor(address _owner) ERC20("CurrencyToken", "CUR") {
        _mint(_owner, 1000000 * 10 ** uint256(18)); // Mint initial supply
    }
}
