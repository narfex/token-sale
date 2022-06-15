//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "./Pool.sol";

contract Factory {

    struct Pools{
        address poolAddress;
        address poolOwner;
        uint256 id;
    }

    IBEP20 public busdAddress; // BUSD address
    IBEP20 public NRFX; // address of Nrafex
    INTokenSale public tokenSaleContract; // address of token-sale contract
    uint256 public pid; // pool id
    address public factoryOwner;

    mapping(uint256 => Pools) public pools;

    constructor(
        IBEP20 _busdAddress,
        IBEP20 _NRFX,
        INTokenSale _tokenSaleContract
        ) {
        busdAddress = _busdAddress;
        NRFX = _NRFX;
        tokenSaleContract = _tokenSaleContract;
        factoryOwner = msg.sender;
    }

    /// @notice creating pool for crowdfunding
    /// @param _maxAmount maximum of crowdfunding amount
    function createPool(uint256 _maxAmount) public {
        require(_maxAmount > 0,"_maxAmount can not be zero");
        pid += 1;
        Pool pool = new Pool(busdAddress, NRFX, tokenSaleContract, factoryOwner, _maxAmount);
        pools[pid].poolAddress = address(pool);
        pools[pid].id = pid;
        
    }

    /// @notice changes owner address of factory
    /// @param _owner the address of new owner
    function changeOwner(address _owner) public {
        require(msg.sender == factoryOwner);
        factoryOwner = _owner;
    }

}
