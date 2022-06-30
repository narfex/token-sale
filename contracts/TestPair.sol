// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

contract TestPair {

    uint112 constant WAD = 10**18;
    address token;
    uint112 reserve0 = 1 * WAD;
    uint112 reserve1 = 2 * WAD;

    constructor(address _token) {
        token = _token;
    }

    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 blockTimestampLast) {
        return (reserve0, reserve1, uint32(block.timestamp));
    }
    
    function token0() external view returns (address) {
        return token;
    }

    function setReserve0(uint112 size) public {
        reserve0 = size;
    }

    function setReserve1(uint112 size) public {
        reserve1 = size;
    }

    function setToken0(address _token) public {
        token = _token;
    }
}
