// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "hardhat/console.sol";

// using PancakeFactory to get price of Narfex in BUSD
interface PancakeFactory {
    function getPair(address _token0, address _token1) external view returns (address pairAddress);
}

interface PancakePair {
    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
}

interface IBEP20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

/// @title Private sale contract for Narfex token in BUSD price
/// @author Viktor Potemkin
/// @notice After 60 days from the date of purchase, users can unlock tokens for the amount equivalent to the deposit in BUSD
/// @notice every 120 days after unlocking from the previous item, users receive 10 percent of the remaining locked amount of Narfex 

contract NTokenSale {

    // user participating in the Narfex private sale
    struct Buyer{
        uint256 numberOfTokens; // locked tokens
        uint256 depositBUSD; // deposit for buy tokens in private sale
        uint256 boughtTime; // time point when user bought token in private sale
        uint256 availableBalance; // token balance to spend
        bool NarfexPayied; // payed numberOfTokens = depositBUSD.mul(priceNarfex) after 60 days
        bool whitelisted; // added to whitelist
        bool bougt; // point when user bought locked tokens
    }

    mapping (address => Buyer) public buyers; 

    IBEP20 public tokenContract;  // the token being sold
    IBEP20 public busdAddress; // payment token address
    address owner; // deployer of contract 
    uint256 public saleSupply; // the number of tokens available for purchase 
    uint256 public timeStartSale; // starting sale point
    uint256 public timeEndSale; // Ending of private sale for whitelist in seconds

    address public pairAddress; // pair Narfex -> BUSD in PancakeSwap
    address public NarfexAddress; // Narfex address for BUSD price
    address public BUSD; // BUSD address in current network
    uint constant WAD = 10 ** 18; // Decimal number with 18 digits of precision

    event Sold(address buyer, uint256 amount);
    event UnlockTokensToBuyers(address buyer, uint256 amount); //after 60 days
    event AddedToWhitelist(address buyer);
    event Withdraw(address buyer, uint256 amount);

    constructor (
        IBEP20  _tokenContract, 
        IBEP20 _busdAddress,
        uint256 _saleSupply,
        uint256 _timeEndSale,
        address _BUSD,
        address _NarfexAddress, 
        address _pairAddress
        ) {
        
        tokenContract = _tokenContract;
        busdAddress = _busdAddress;
        saleSupply = _saleSupply;
        timeEndSale = _timeEndSale;
        BUSD = _BUSD;
        NarfexAddress = _NarfexAddress;
        pairAddress = _pairAddress;
        timeStartSale = block.timestamp;
        owner = msg.sender;
        buyers[owner].whitelisted = true;
    }

    /// @notice verification of private purchase authorization
    modifier onlyWhitelisted() {
        require(isWhitelisted(msg.sender), "You are not in whitelist");
        _;
    }

    //Guards against integer overflows
    function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        } else {
            uint256 c = a * b;
            assert(c / a == b);
            return c;
        }
    }

    // Guards for div
    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /// @notice users buy locked tokens by transferring BUSD to this contract 
    /// @param amount Amount of BUSD tokens to deposit
<<<<<<< HEAD
    function buyTokens(uint256 amount) public  onlyWhitelisted {
=======
    function buyTokens(uint256 amount) public onlyWhitelisted(){
>>>>>>> 2b0c7161e886e320e078e7e91ca01158b910be2e
        address _msgSender = msg.sender; 

        require(!buyers[_msgSender].bougt);
        require(block.timestamp - timeStartSale < timeEndSale, "Sorry, sale already end");
        amount = amount * WAD;
        saleSupply = saleSupply * WAD;
        uint256 scaledAmount = amount * 10 / 4;
        console.log("scaledAmount", scaledAmount);
        require(scaledAmount <= saleSupply, "You can not buy more than maximum supply");
        require(tokenContract.balanceOf(address(this)) >= scaledAmount);
        saleSupply = saleSupply - scaledAmount;
        buyers[_msgSender].depositBUSD = amount;
        buyers[_msgSender].boughtTime = block.timestamp;
        buyers[_msgSender].bougt = true;
        buyers[_msgSender].numberOfTokens = scaledAmount;
        
        busdAddress.transferFrom(_msgSender, address(this), amount);

        emit Sold(_msgSender, scaledAmount);
    }

    /// @notice allows users to withdraw unlocked tokens
    /// @param _numberOfTokens amount of Narfex tokens to withdraw
    function withdraw(uint256 _numberOfTokens) public onlyWhitelisted {
        address _msgSender = msg.sender; // lower gas

        require (buyers[_msgSender].availableBalance >= _numberOfTokens, "Not enough tokens to withdraw");
        require(tokenContract.balanceOf(address(this)) >= _numberOfTokens, "Not enough tokens in contract");

        buyers[_msgSender].availableBalance -= _numberOfTokens;
        tokenContract.transfer(_msgSender, _numberOfTokens);
        emit Withdraw (_msgSender, _numberOfTokens);
    }

    /// @notice allows users to unlock tokens after a certain period of time
    function unlock() public onlyWhitelisted {
        address _msgSender = msg.sender;
        uint256 unlockToBalance;
        if (!buyers[_msgSender].NarfexPayied) {
            // Unlock tokens after 60 days for buyers 
            require (block.timestamp - buyers[_msgSender].boughtTime >= 60 seconds); //

            buyers[_msgSender].NarfexPayied = true;
            // sub 60 days and from this point unlocking 10% every 120 days 
            buyers[_msgSender].boughtTime -= 60 seconds; 
            unlockToBalance = buyers[_msgSender].depositBUSD * WAD / getUSDPrice(NarfexAddress);
            buyers[_msgSender].depositBUSD = 0;
    
        } else {
            // Unlock 10% tokens after 120 days for buyers
            require (block.timestamp - buyers[_msgSender].boughtTime >= 120 seconds);
            buyers[_msgSender].boughtTime = block.timestamp;

            // calculating 10% for user
            unlockToBalance =  (buyers[_msgSender].numberOfTokens * 100) / 1000;

        }

        if (buyers[_msgSender].numberOfTokens < unlockToBalance) {
            unlockToBalance = buyers[_msgSender].numberOfTokens;
        }
        buyers[_msgSender].numberOfTokens -= unlockToBalance;
        buyers[_msgSender].availableBalance += unlockToBalance;
        
        emit UnlockTokensToBuyers(_msgSender, unlockToBalance);
    }

    /// @notice send from this contract unsold tokens and deposited BUSD tokens to the owner
    function endSale() public {
        address _msgSender = msg.sender;
        require(_msgSender == owner);
        require(block.timestamp - timeStartSale >= timeEndSale, "Sorry, sale has not ended yet");

        // Send unsold tokens to the owner
        tokenContract.transfer(_msgSender, tokenContract.balanceOf(address(this)));
        // Send BUSD tokens to the owner
        busdAddress.transfer(_msgSender, busdAddress.balanceOf(address(this)));
    }

    /// @notice check allowance for user to buy in private sale
    /// @param _address address of user for check allowance
    function isWhitelisted(address _address) public view returns(bool) {
        return buyers[_address].whitelisted;
    }

    /// @notice add to whitelist user
    /// @param _address address of user for add to whitelist
    function addWhitelist(address _address) public {
        require(msg.sender == owner);

        buyers[_address].whitelisted = true;
        emit AddedToWhitelist(_address);
    }


    /// @notice get ratio for pair from Pancake
    /// @param _token0 the address of Narfex
    /// @param _token1 the address of BUSD
    /// @return returns ratio in a decimal number with 18 digits of precision
    function getRatio(address _token0, address _token1) public view returns (uint) {
        PancakePair pair = PancakePair(pairAddress);
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = pair.getReserves();
        if (NarfexAddress == _token0) {
            return reserve1 * WAD / reserve0;
        } else {
            return reserve0 * WAD / reserve1;
        }
    }

    /// @notice get price of token in BUSD from Pancake pair
    /// @param _token the address of Narfex (address of toren for price in BUSD)
    /// @return returns token BUSD price in a decimal number with 18 digits of precision
    function getUSDPrice(address _token) public view returns (uint) {
        if (_token == BUSD) {
            return WAD;
        } else {
            return getRatio(_token, BUSD);
        }
    }

<<<<<<< HEAD
    function getBalanceBUSD() public view returns(uint256){
=======
    function getBalanceBUSD() public returns(uint256){
>>>>>>> 2b0c7161e886e320e078e7e91ca01158b910be2e
        return busdAddress.balanceOf(address(this));
    }

    function getBalanceNarfex() public view returns(uint256){
        return tokenContract.balanceOf(address(this));
    }

    function getYourBalanceBUSD() public view returns(uint256){
        return busdAddress.balanceOf(msg.sender);
    }

    function getYourBalanceNarfex() public view returns(uint256){
        return tokenContract.balanceOf(msg.sender);
    }
}

<<<<<<< HEAD
=======

>>>>>>> 2b0c7161e886e320e078e7e91ca01158b910be2e
