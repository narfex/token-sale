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
        uint256 unlocktTime; // time point when user unlock tokens
        uint256 availableBalance; // token balance to spend
        bool NarfexPayied; // payed numberOfTokens = depositBUSD.mul(priceNarfex) after 60 days
        bool whitelisted; // added to whitelist
    }

    mapping (address => Buyer) public buyers; 

    IBEP20 public tokenContract;  // the token being sold
    IBEP20 public busdAddress; // payment token address
    address owner; // deployer of contract 
    uint256 public saleSupply; // the number of tokens available for purchase 
    uint256 public timeStartSale; // starting sale point
    uint256 public timeEndSale; // Ending of private sale for whitelist in seconds
    uint256 public minAmountForUser; // minimum amount of deposit to buy in busd for each user
    uint256 public maxAmountForUser; // maximum amount of deposit for sale in busd for each user
    bool public saleStarted; // from this point sale is started

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
        address _pairAddress,
        uint256 _minAmountForUser,
        uint256 _maxAmountForUser
        ) {
        
        tokenContract = _tokenContract;
        busdAddress = _busdAddress;
        saleSupply = _saleSupply;
        timeEndSale = _timeEndSale;
        BUSD = _BUSD;
        NarfexAddress = _NarfexAddress;
        pairAddress = _pairAddress;
        minAmountForUser = _minAmountForUser;
        maxAmountForUser = _maxAmountForUser;
        owner = msg.sender;
        buyers[owner].whitelisted = true;
    }

    /// @notice verification of private purchase authorization
    modifier onlyWhitelisted() {
        require(isWhitelisted(msg.sender), "You are not in whitelist");
        _;
    }

    /// @notice verification of owner
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /// @notice starting sale with pairAddress of Narfex-BUSD in PancakeSwap
    function startSale(uint256 _timeEndSale) public onlyOwner {
        //require(!saleStarted);
        timeStartSale = block.timestamp;
        saleStarted = true;
        timeEndSale = _timeEndSale;
        saleSupply = saleSupply * WAD;
        minAmountForUser = minAmountForUser * WAD;
        maxAmountForUser = maxAmountForUser * WAD;
    }

    /// @notice change pairAddress
    /// @param _pairAddress address of Narfex-BUSD in PancakeSwap
    function changePairAddress(address _pairAddress) public onlyOwner {
        pairAddress = _pairAddress;
    }

    /// @notice users buy locked tokens by transferring BUSD to this contract 
    /// @param amount Amount of BUSD tokens to deposit in wei (10**18)
    function buyTokens(uint256 amount) public onlyWhitelisted {
        address _msgSender = msg.sender; 

        require(saleStarted, "Sorry, sale not started");
        require(block.timestamp - timeStartSale < timeEndSale, "Sorry, sale already end");
        require(amount >= minAmountForUser, "You must deposit more than 30 thousand BUSD");
        require(amount <= maxAmountForUser - buyers[_msgSender].depositBUSD, "You have exceeded the purchase limit BUSD");
        uint256 scaledAmount = amount * 10 / 4;
        require(scaledAmount <= saleSupply, "You can not buy more than maximum supply");
        saleSupply = saleSupply - scaledAmount;
        buyers[_msgSender].depositBUSD = amount;
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
        require(block.timestamp - timeStartSale > timeEndSale);
        if (!buyers[_msgSender].NarfexPayied) {
            // Unlock tokens after 60 days for buyers 
            require (block.timestamp - timeStartSale >= timeEndSale + 2 minutes); 
            buyers[_msgSender].NarfexPayied = true;
            buyers[_msgSender].unlocktTime = block.timestamp;
            unlockToBalance = buyers[_msgSender].depositBUSD * WAD / getUSDPrice(NarfexAddress);
            buyers[_msgSender].depositBUSD = 0;
    
        } else {
            // Unlock 10% tokens after 120 days for buyers
            require (block.timestamp - buyers[_msgSender].unlocktTime >= 2 minutes);
            buyers[_msgSender].unlocktTime = block.timestamp;
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
    function saleEnded() public onlyOwner{
        require(block.timestamp - timeStartSale >= timeEndSale, "Sorry, sale has not ended yet");
        // Send unsold tokens to the owner
        tokenContract.transfer(owner, saleSupply);
        // Send BUSD tokens to the owner
        busdAddress.transfer(owner, busdAddress.balanceOf(address(this)));
    }

    /// @notice check allowance for user to buy in private sale
    /// @param _address address of user for check allowance
    function isWhitelisted(address _address) public view returns(bool) {
        return buyers[_address].whitelisted;
    }

    /// @notice add to whitelist user
    /// @param _address address of user for add to whitelist
    function addWhitelist(address _address) public onlyOwner{
        buyers[_address].whitelisted = true;
        emit AddedToWhitelist(_address);
    }

    /// @notice changes owner address for adding in whitelist users
    /// @param _address the address of new owner
    /// @return returns address of new owner
    function changeOwner(address _address) public onlyOwner returns(address){
        owner = _address;
        addWhitelist(_address);
        return owner;
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

    /// @notice get amount of BUSD in this contract
    /// @return returns amount of BUSD in this contract
    function getBalanceBUSD() public view returns(uint256){
        return busdAddress.balanceOf(address(this));
    }

    /// @notice get amount of Narfex in this contract
    /// @return returns amount of Narfex in this contract
    function getBalanceNarfex() public view returns(uint256){
        return tokenContract.balanceOf(address(this));
    }
}
