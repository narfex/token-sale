//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "./Pool.sol";

contract Factory {

    struct Pools{
        address poolAddress; // address of pool
        address poolOwner; // address of pool's owner
        uint256 maxAmount; // maximum supply of deposit to all users in this pool
    }

    IBEP20 public busdAddress; // BUSD address
    IBEP20 public NRFX; // address of Nrafex
    INarfexTokenSale public tokenSaleContract; // address of token-sale contract
    address public factoryOwner; // owner of factory
    uint256 public minUserAmount; // minimum deposit for user in pools
    uint256 public maxUserAmount; // maximum deposit for user in pools

    mapping(address => Pools) public pools;
    address[] public poolsList;

    modifier onlyFactoryOwner {
        require(msg.sender == factoryOwner, "You are not factory owner");
        _;
    }

    constructor(
        IBEP20 _busdAddress,
        IBEP20 _NRFX,
        INarfexTokenSale _tokenSaleContract,
        address _factoryOwner,
        uint _minUserAmount,
        uint _maxUserAmount
        ) {
        busdAddress = _busdAddress;
        NRFX = _NRFX;
        tokenSaleContract = _tokenSaleContract;
        factoryOwner = _factoryOwner;
        minUserAmount = _minUserAmount;
        maxUserAmount = _maxUserAmount;
    }

    /// @notice creating pool for crowdfunding
    /// @param _maxAmount maximum of crowdfunding amount
    function createPool(uint256 _maxAmount) public {
        address _msgSender = msg.sender;
        require(_maxAmount > 0,"_maxAmount can not be zero");
        require(pools[_msgSender].poolOwner != _msgSender,"You can create a pool only once");
        Pool pool = new Pool(busdAddress, NRFX, tokenSaleContract, factoryOwner, _maxAmount, minUserAmount, maxUserAmount);
        poolsList.push(address(pool));
        pools[_msgSender].poolAddress = address(pool);
        pools[_msgSender].maxAmount = _maxAmount;
        pools[_msgSender].poolOwner = _msgSender;
    }

    /// @notice changes owner address of factory
    /// @param _owner the address of new owner
    function changeOwner(address _owner) public onlyFactoryOwner{
        factoryOwner = _owner;
    }

    /// @notice set minimum deposit for user in pools
    /// @param _minUserAmount new minimum deposit for user in pools
    function setMinUserAmount(uint256 _minUserAmount) public onlyFactoryOwner{
        minUserAmount = _minUserAmount;
    }

    /// @notice set maximum deposit for user in pools
    /// @param _maxUserAmount new maximum deposit for user in pools
    function setMaxUserAmount(uint256 _maxUserAmount) public onlyFactoryOwner{
        maxUserAmount = _maxUserAmount;
    }

    /// @notice Returns poolsList length
    /// @return Pools count
    function getPoolsCount() external view returns (uint) {
        return poolsList.length;
    }

}
