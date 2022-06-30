// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

interface PancakePair {
    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1);
    function token0() external view returns (address);
}

interface IBEP20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract NarfexPrivateSale {

    struct User {
        bool isWhitelisted;
        uint deposit;
        uint narfexLocked;
        uint profit;
        uint withdrawn;
    }
    mapping (address => User) public users;
    address[] usersList;

    address public owner;

    IBEP20 public NRFX;
    IBEP20 public BUSD;
    PancakePair public pair;

    uint constant WAD = 10 ** 18;
    uint constant DAY = 60 * 60 * 24;
    uint public profitFractination = 10 * WAD / 100;
    uint public minUserAmount = 30000 * WAD;
    uint public maxUserAmount = 100000 * WAD;

    uint public saleStartTime;
    uint public saleEndTime;
    uint public depositLockupPeriod = 60 * DAY;
    uint public profitLockupPeriod = 120 * DAY;

    uint public narfexReserved;
    uint public narfexStartPrice = 4 * WAD / 10;
    uint public narfexEndPrice;

    constructor (
        IBEP20 _nrfxAddress,
        IBEP20 _busdAddress,
        PancakePair _pair,
        uint _minUserAmount,
        uint _maxUserAmount,
        uint _depositLockupPeriod,
        uint _profitLockupPeriod,
        uint _narfexStartPrice
    ) {
        owner = msg.sender;
        NRFX = IBEP20(_nrfxAddress);
        BUSD = IBEP20(_busdAddress);
        pair = PancakePair(_pair);
        minUserAmount = _minUserAmount > 0 ? _minUserAmount : minUserAmount;
        maxUserAmount = _maxUserAmount > 0 ? _maxUserAmount : maxUserAmount;
        depositLockupPeriod = _depositLockupPeriod > 0 ? _depositLockupPeriod : depositLockupPeriod;
        profitLockupPeriod = _profitLockupPeriod > 0 ? _profitLockupPeriod : profitLockupPeriod;
        narfexStartPrice = _narfexStartPrice > 0 ? _narfexStartPrice : narfexStartPrice;
    }

    modifier onlyWhitelisted() {
        require(isWhitelisted(msg.sender), "You are not in whitelist");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    event Whitelisted(address _address);
    event SaleStarted(uint _startTime, uint _endTime);
    event PriceLock(uint _price);
    event NotEnoughNarfexForProfits(uint _reserved, uint _currentBalance);
    event Buy(address _user, uint _busdAmount, uint _narfexAmount);
    event Withdraw(address _user, uint _amount);
    event CollectBUSD(address _user, uint _amount);
    event CollectSurplus(address _user, uint _amount);

    function transferOwnership(address _address) public onlyOwner {
        owner = _address;
    }

    function isWhitelisted(address _address) public view returns(bool) {
        return users[_address].isWhitelisted;
    }

    function addToWhitelist(address _address) public onlyOwner {
        users[_address].isWhitelisted = true;
        usersList.push(_address);
        emit Whitelisted(_address);
    }

    function getNarfexPrice() public view returns (uint) {
        (uint112 reserve0, uint112 reserve1) = pair.getReserves();
        if (address(NRFX) == pair.token0()) {
            return reserve1 * WAD / reserve0;
        } else {
            return reserve0 * WAD / reserve1;
        }
    }

    function getBusdBalance() public view returns(uint) {
        return BUSD.balanceOf(address(this));
    }

    function getNarfexBalance() public view returns(uint) {
        return NRFX.balanceOf(address(this));
    }

    function getNarfexAvailable() public view returns(uint) {
        return getNarfexBalance() - narfexReserved;
    }

    function isSaleStarted() public view returns(bool) {
        return saleStartTime > 0;
    }

    function isSaleEnded() public view returns(bool) { 
        return 0 < saleEndTime && saleEndTime <= block.timestamp;
    }

    function isSaleActive() public view returns(bool) {
        return isSaleStarted() && !isSaleEnded();
    }

    function isDepositUnlocked() public view returns(bool) {
        return isSaleEnded() && saleEndTime + depositLockupPeriod <= block.timestamp;
    }

    function getUnlockIndex() public view returns(uint) {
        return isDepositUnlocked()
            ? (block.timestamp - (saleEndTime + depositLockupPeriod)) / profitLockupPeriod
            : 0;
    }

    function startSale(uint _salePeriod) public onlyOwner {
        require(!isSaleStarted(), "Sale already started");
        saleStartTime = block.timestamp;
        saleEndTime = block.timestamp + _salePeriod;
        emit SaleStarted(saleStartTime, saleEndTime);
    }

    function getNarfexAmount(uint _deposit, uint _price) public view returns(uint) {
        return _deposit * WAD / (_price > 0 ? _price : getNarfexPrice());
    }

    function buy(uint _amount) public onlyWhitelisted {
        require(isSaleStarted(), "Sorry, the sale has not started yet");
        require(!isSaleEnded(), "Sorry, the sale has already ended");
        require(_amount >= minUserAmount, "Too small deposit");
        require(_amount <= maxUserAmount, "Too big deposit");

        // Calculate guaranteed number of tokens
        uint narfexAmount = getNarfexAmount(_amount, narfexStartPrice);
        require(narfexAmount <= getNarfexAvailable(), "Sorry, there is not enough sale supply");

        address sender = msg.sender;
        users[sender].deposit = _amount;
        users[sender].narfexLocked = narfexAmount;
        // Reserve this Narfex amount on the contract
        narfexReserved += narfexAmount;
        BUSD.transferFrom(sender, address(this), _amount);
        emit Buy(sender, _amount, narfexAmount);
    }

    function lockNarfexPrice(uint _price) internal {
        if (narfexEndPrice > 0) return; // End price already locked
        narfexEndPrice = _price > 0 ? _price : getNarfexPrice();
        // Narfex end price can't be lower than start price. Users are insured against loss of deposit
        if (narfexEndPrice < narfexStartPrice) narfexEndPrice = narfexStartPrice;
        // Lock Narfex for each user
        for (uint i = 0; i < usersList.length; i++) {
            User storage user = users[usersList[i]];
            uint depositEquivalent = getNarfexAmount(user.deposit, narfexEndPrice);
            user.profit = user.narfexLocked - depositEquivalent;
            // Extend the tokens reservation to the current profit
        }
        emit PriceLock(narfexEndPrice);
        // Check the current Narfex balance. It should be enough to pay profits
        uint balance = getNarfexBalance();
        if (narfexReserved > balance) emit NotEnoughNarfexForProfits(narfexReserved, balance);
    }

    function payToUser(address _address, uint _amount) internal {
        require(getNarfexBalance() >= _amount, "Sorry, there is not enough sale supply");
        User storage user = users[_address];
        user.withdrawn += _amount;
        user.narfexLocked -= _amount;
        // Decrease common reserve
        narfexReserved -= _amount;
        NRFX.transfer(_address, _amount);
    }

    function getAvailableToWithdraw(address _address) public view returns(uint) {
        if (!isDepositUnlocked()) return 0;
        User storage user = users[_address];
        if (!user.isWhitelisted) return 0;

        // Index of unlock period
        uint index = getUnlockIndex();
        // Narfex amount for each period
        uint profitFraction = user.profit * profitFractination / WAD;
        // The number of Narfex equivalent to deposited BUSD amount
        uint depositEquivalent = getNarfexAmount(user.deposit, narfexEndPrice);
        // How much should have been paid by now
        uint availableNow = index == 0
            ? depositEquivalent
            : depositEquivalent + profitFraction * index;
        // Subtract what has already been paid
        return availableNow - user.withdrawn;
    }

    function withdraw() public onlyWhitelisted {
        require(isDepositUnlocked(), "Lockup period is not over yet");

        if (narfexEndPrice == 0) {
            // The user is the first to withdraw tokens. Fix the price first
            lockNarfexPrice(0);
        }

        address sender = msg.sender;
        uint amount = getAvailableToWithdraw(sender);
        require(amount > 0, "You do not have funds to withdraw");
        payToUser(sender, amount);
        emit Withdraw(sender, amount);
    }

    function sendBusdToOwner() public onlyOwner {
        uint balance = getBusdBalance();
        BUSD.transfer(owner, balance);
        emit CollectBUSD(owner, balance);
    }

    function sendNarfexToOwner() public onlyOwner {
        require(isSaleEnded(), "The sale is not ended - reserves not yet determined");
        uint available = getNarfexBalance() - narfexReserved;
        require(available > 0, "No Narfex available to collect");
        NRFX.transfer(owner, available);
        emit CollectSurplus(owner, available);
    }

    function forceSaleEnd() public onlyOwner {
        require(isSaleActive(), "Sale is not active");
        saleEndTime = block.timestamp;
    }

    function changeSaleEnd(uint _timestamp) public onlyOwner {
        require(isSaleActive(), "You can extend only active sale");
        saleEndTime = _timestamp;
    }

    function forceUnlockDeposit() public onlyOwner {
        require(isSaleEnded(), "Sale still not ended");
        require(narfexEndPrice == 0, "Deposit already unlocked");
        // Make first lockup period shorter
        depositLockupPeriod = block.timestamp - saleEndTime;
        // Lock current Narfex price
        lockNarfexPrice(0);
    }

    function setMinUserAmount(uint _amount) public onlyOwner {
        minUserAmount = _amount;
    }

    function setMaxUserAmount(uint _amount) public onlyOwner {
        maxUserAmount = _amount;
    }

    function setProfitFractination(uint _percents) public onlyOwner {
        require(!isSaleStarted(), "You can't change the rules after the sale start");
        require(_percents <= WAD, "The fraction can't be higher than 100%");
        require(_percents > WAD / 100 * 5, "Too small fraction. Minimum is 5%");
        profitFractination = _percents;
    }

    function setDepositLockupPeriod(uint _seconds) public onlyOwner {
        require(!isDepositUnlocked(), "Deposits is already unlocked");
        if (isSaleStarted()) {
            require(_seconds < depositLockupPeriod, "After the start of sales, you can only shorten the period");    
        }
        depositLockupPeriod = _seconds;
    }

    function setProfitLockupPeriod(uint _seconds) public onlyOwner {
        if (isSaleStarted()) {
            require(_seconds < profitLockupPeriod, "After the start of sales, you can only shorten the period");    
        }
        profitLockupPeriod = _seconds;
    }

    function setStartNarfexPrice(uint _price) public onlyOwner {
        require(!isSaleStarted(), "You can't change the demand after the sale start");
        require(_price > 0, "The price can't be equal zero");
        narfexStartPrice = _price;
    }

    function getNextUnlockTime() public view returns(uint) {
        if (!isSaleStarted()) return 0;
        if (!isSaleEnded()) return saleEndTime;
        if (!isDepositUnlocked()) return saleEndTime + depositLockupPeriod;
        return saleEndTime + depositLockupPeriod + (getUnlockIndex() + 1) * profitLockupPeriod;
    }

}