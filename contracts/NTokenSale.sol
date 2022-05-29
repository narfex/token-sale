// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

// uising PancakeFactory to get price of Narfex in BUSD
abstract contract PancakeFactory {
    function getPair(address _token0, address _token1) external view virtual returns (address pairAddress);
}

abstract contract PancakePair {
    address public token0;
    address public token1;
    function getReserves() public view virtual returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
}

interface IERC20 {
    function balanceOf(address _owner) external returns (uint256);
    function transfer(address _to, uint256 _amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}



// whitelst users buy Narfex token for BUSD
// after 60 days, they have the right to unlock tokens for the amount equivalent to the deposit in BUSD
// every 120 days after unlocking from the previous item
// users receive 10 percent of the remaining locked amount of Narfex 
/// @author Viktor Potemkin

contract NTokenSale {

    // user participating in the Narfex private sale
    struct Buyer{
        uint256 numberOfTokens; // locked tokens
        uint256 depositBUSD; // deposit for buy tokens in private sale
        uint256 boughtTime; // time point when user bought token in private sale
        uint256 availableBalance; // token balance to spend
        bool NarfexPayied; // payed numberOfTokens = depositBUSD.mul(priceNarfex) after 60 days
        bool whitelisted; // added to whitelist
    }

    mapping (address => Buyer) public buyers; 

    IERC20 public tokenContract;  // the token being sold
    IERC20 public busdAddress; // payment token address
    address owner; // deployer of contract 
    uint256 public saleSupply; // the number of tokens available for purchase 
    uint256 public timeStartSale; // starting sale point
    uint256 public timeEndSale; // Ending of private sale for whitelist in seconds
    uint256 public firstNarfexPrice; // price of tokens in private sale 

    address public NarfexAddress; // Narfex address for BUSD price
    address public factoryAddress; // PancakeFactory for pairs getting
    address public BUSD; // BUSD address in current network
    uint constant WAD = 10 ** 18; // Decimal number with 18 digits of precision

    event Sold(address buyer, uint256 amount);
    event UnlockTokensToBuyers(address buyer, uint256 amount); //after 60 days
    event AddedToWhitelist(address buyer);
    event Withdraw(address buyer, uint256 amount);

    constructor (
        IERC20  _tokenContract,
        IERC20 _busdAddress,
        uint256 _saleSupply,
        uint256 _timeEndSale,
        address _factory,
        address _BUSD,
        address _NarfexAddress,
        uint256 _firstNarfexPrice
        ) {
        
        tokenContract = _tokenContract;
        busdAddress = _busdAddress;
        saleSupply = _saleSupply;
        timeEndSale = _timeEndSale;
        factoryAddress = _factory;
        BUSD = _BUSD;
        NarfexAddress = _NarfexAddress;
        firstNarfexPrice = _firstNarfexPrice;
        timeStartSale = block.timestamp;
        owner = msg.sender;
    }

    // verification of private purchase authorization
    modifier onlyWhitelisted() {
        require(isWhitelisted(msg.sender), "You are not in whitelist");
        _;
    }

    // // Guards against integer overflows
    // function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
    //     if (a == 0) {
    //         return 0;
    //     } else {
    //         uint256 c = a * b;
    //         assert(c / a == b);
    //         return c;
    //     }
    // }

    // // Guards for div
    // function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
    //     require(b > 0, "SafeMath: division by zero");
    //     return a / b;
    // }

    // users buy locked tokens by transferring BUSD to this contract 
    function buyTokens(uint256 amount) public onlyWhitelisted(){
        address _msgSender = msg.sender; 

        require(block.timestamp - timeStartSale < timeEndSale, "Sorry, sale already end");
        
        uint256 scaledAmount = amount / firstNarfexPrice;

        require(scaledAmount <= saleSupply, "You can not buy more than maximum supply");
        require(tokenContract.balanceOf(address(this)) >= scaledAmount);

        saleSupply -= scaledAmount;
        buyers[_msgSender].depositBUSD = amount;
        buyers[_msgSender].boughtTime = block.timestamp;
        buyers[_msgSender].numberOfTokens = scaledAmount;

        busdAddress.transferFrom(_msgSender, address(this), amount);

        emit Sold(_msgSender, scaledAmount);
    }

    // withdraw unlocked tokens
    function withdraw(uint256 _numberOfTokens) public onlyWhitelisted() {
        address _msgSender = msg.sender; // lower gas

        require (buyers[_msgSender].availableBalance >= _numberOfTokens, "Not enough tokens to withdraw");
        require(tokenContract.balanceOf(address(this)) >= _numberOfTokens, "Not enough tokens in contract");

        buyers[_msgSender].availableBalance -= _numberOfTokens;
        tokenContract.transfer(_msgSender, _numberOfTokens);
        emit Withdraw (_msgSender, _numberOfTokens);
    }

    // allows users to unlock tokens after a certain period of time
    function unlock() public onlyWhitelisted {
        address _msgSender = msg.sender;
        uint256 unlockToBalance;
        if (!buyers[_msgSender].NarfexPayied) {
            // Unlock tokens after 60 days for buyers 
            require (block.timestamp - buyers[_msgSender].boughtTime >= 60 days); //

            buyers[_msgSender].NarfexPayied = true;
            // sub 60 days and from this point unlocking 10% every 120 days 
            buyers[_msgSender].boughtTime -= 60 days; 
            unlockToBalance = buyers[_msgSender].depositBUSD / getUSDPrice(NarfexAddress);
            buyers[_msgSender].depositBUSD = 0;
    
        } else {
            // Unlock 10% tokens after 120 days for buyers
            require (block.timestamp - buyers[_msgSender].boughtTime >= 120 days);
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

    // Send unsold tokens and BUST tokens to the owner
    function endSale() public {
        address _msgSender = msg.sender;
        require(_msgSender == owner);
        require(block.timestamp >= timeEndSale, "Sorry, sale has not ended yet");

        // Send unsold tokens to the owner
        tokenContract.transfer(_msgSender, tokenContract.balanceOf(address(this)));
        // Send BUSD tokens to the owner
        busdAddress.transfer(_msgSender, busdAddress.balanceOf(address(this)));
    }

    // check allowance for user to buy in private sale
    function isWhitelisted(address _address) public view returns(bool) {
        return buyers[_address].whitelisted;
    }

    // Allow user to buy in private sale (add to whitelist)
    function addWhitelist(address _address) public {
        require(msg.sender == owner);

        buyers[_address].whitelisted = true;
        emit AddedToWhitelist(_address);
    }

    // Returns pair address from PancakeFactory
    function getPair(address _token0, address _token1) public view returns (address pairAddress) {
        PancakeFactory factory = PancakeFactory(factoryAddress);
        return factory.getPair(_token0, _token1);
    }

    // Returns ratio in a decimal number with 18 digits of precision
    function getRatio(address _token0, address _token1) public view returns (uint) {
        PancakePair pair = PancakePair(getPair(_token0, _token1));
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = pair.getReserves();
        if (pair.token0() == _token0) {
            return reserve1 * WAD / reserve0;
        } else {
            return reserve0 * WAD / reserve1;
        }
    }

    // Returns token USD price in a decimal number with 18 digits of precision
    function getUSDPrice(address _token) public view returns (uint) {
        if (_token == BUSD) {
            return WAD;
        } else {
            return getRatio(_token, BUSD);
        }
    }

}