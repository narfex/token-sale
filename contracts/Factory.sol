//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "./Pool.sol";

contract Factory {

    IBEP20 public busdAddress; // BUSD address
    IBEP20 public NRFX; // address of Nrafex
    NTokenSale public tokenSaleContract; // address of token-sale contract
    uint256 public pid; // pool id
    address public owner;

    mapping(uint256 => address) public pools;

    constructor(
        IBEP20 _busdAddress,
        IBEP20 _NRFX,
        NTokenSale _tokenSaleContract
        ) {
        busdAddress = _busdAddress;
        NRFX = _NRFX;
        tokenSaleContract = _tokenSaleContract;
        owner = msg.sender;
    }

    /// @notice creating pool for crowdfunding
    function createPool() public returns(uint256) {
        pid += 1;
        Pool pool = new Pool(busdAddress, NRFX, tokenSaleContract);
        pools[pid] = address(pool);
        return pid;
    }

    /// @notice changes owner address of factory
    /// @param _owner the address of new owner
    function changeOwner(address _owner) public {
        require(msg.sender == _owner);
        owner = _owner;
    }

}