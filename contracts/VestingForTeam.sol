// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

interface IBEP20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

/// @title Vesting contract for Narfex team
/// @author Potemkin Viktor
/// @notice Transfering every 6 month 10% of Narfex tokens from all team supply
// address in bsc mainnet 0x740081287885D35691F9b85A5792D65B4d8d9DE4

contract VestingForTeam {

    IBEP20 public tokenContract;  // the token being sold
    address public owner; // owner (ceo Narfex)
    uint256 public timestampPercantageUnlock; // point in time for unlock
    uint256 public amountPercantageUnlock; // amount of 10% for unlock
    bool public calculatedAmountPercantageUnlock; // allow to calculate amountPercantageUnlock only once

    event ClaimNRFX(address owner, uint256 amount);
    event GetAmountPercantageUnlock(uint256 amountPercantageUnlock, bool calculatedAmountPercantageUnlock);

    constructor (
        IBEP20  tokenContract_, 
        address owner_
        ) {
        tokenContract = tokenContract_;
        owner = owner_;
        timestampPercantageUnlock = block.timestamp;
    }

    /// @notice verification of owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    /// @notice this function withdrawal every half of year 10% of Narfex tokens from all supply for team
    function claimNRFX() public onlyOwner {
        require(
            block.timestamp - timestampPercantageUnlock >= 183 days,
            "Wait half an year"
        );
        require(
            calculatedAmountPercantageUnlock,
            "Calculate amountPercantageUnlock"
        );

        timestampPercantageUnlock += 183 days;
        tokenContract.transfer(owner, amountPercantageUnlock);

        emit ClaimNRFX(owner, amountPercantageUnlock);
    }

    /// @notice calculate 10% for unlock
    function getAmountPercantageUnlock() public onlyOwner {
        require(
            !calculatedAmountPercantageUnlock,
            "Calculated only once"
        );
        require(
            tokenContract.balanceOf(address(this)) > 0,
            "You should have Narfex on Balance"
        );

        amountPercantageUnlock = tokenContract.balanceOf(address(this)) * 100 / 1000;
        calculatedAmountPercantageUnlock = true;

        emit GetAmountPercantageUnlock(amountPercantageUnlock, calculatedAmountPercantageUnlock);
    }

}
