## ***How to participate in the purchase `Narfex`***
1. Sale starts when `owner` write in function `timeEndSale` in seconds:
```solidity
    function startSale(uint256 _timeEndSale)
```
 you have `timeEndSale` to participate in the `token-sale`

2. To participate in the `token-sale`, you must be authorized to buy. To do this, the owner of the contract must add your address to the `whitelist`
```solidity
    function addWhitelist(address _address)
```
   In this case, `address` is address of user, whose allowed to buy tokens.
    P.S. in testnet version you have not be in whitelist to buy
On successful execution of the function, event is generated
`AddedToWhitelist(_address)`
   

3. Then you should deposit your BUSD tokens to buy Narfex by `firstNarfexPrice` - fixed price of Narfex in this sale
```solidity
   function buyTokens(uint256 amount)
```
   `amount` it is your deposit in BUSD (in wei). Your tokens will be locked in this contract for period of time
   
On successful execution of the function, event is generated
`Sold(_msgSender, scaledAmount)`
   
4. After `firstUnlock` time from `timeEndSale` you have allowance to unlock tokens for the amount equivalent to the deposit in BUSD. And every `percantageUnlock` time after unlocking from the previous item, you can receive 10 percent of the remaining locked amount of Narfex.
```solidity
   function unlock()
```

On successful execution of the function, event is generated
`UnlockTokensToBuyers(_msgSender, unlockToBalance)`

5. You can also `withdraw` any unlocked amount of Narfex tokens available to you at any time.   
```solidity
   function withdraw(uint256 _numberOfTokens)
```
   `_numberOfTokens` - amont of tokens which you would like to spend
   
On successful execution of the function, event is generated
` Withdraw (_msgSender, _numberOfTokens)`

## ***For now you already know how to buy Narfex in private sale, Good luck***

## ***To unlocking Narfex after `firstUnlock`***
1. We using price in BUSD from `PancakeFactory`
```solidity
   function getUSDPrice(address _token)
```
    In this case, `_token` is address of Narfex, in PancakeFactory.

## ***For now you already know how to buy Narfex in private sale, Good luck***

## ***To unlocking Narfex after `firstUnlock`***
1. We using price in BUSD from `PancakeFactory`
```solidity
   function getUSDPrice(address _token)
```
    In this case, `_token` is address of Narfex, in PancakeFactory.
    
## ***Variables for each buyer***

`narfexAmount` // Current narfex amount left //
`tenPercents` // Narfex amount left after the first unlock //
`busdDeposit` // deposit for buy tokens in private sale //
`unlockTime` // time point when user unlock tokens //
`availableBalance` // token balance to withdraw //
`isNarfexPayed` // payed narfexAmount = busdDeposit.mul(priceNarfex) after 60 days //
`isWhitelisted` // added to whitelist //

## ***Variables in contract***

`narfexContract`  // IBEP20 the token being sold //

`busdAddress` // IBEP20 payment token address //

`owner` // deployer of contract //

`saleStartTime` // starting sale point //

`toEndSecondsAmount` // period of time in seconds for private sale for whitelist users //

`minAmountForUser` // minimum amount of deposit in busd to buy for each user //

`maxAmountForUser` // maximum amount of deposit in busd for each user //

`isSaleStarted` // from this point sale is started //

`firstUnlockSeconds` // period of time for unlock 100% BUSD price //

`percentageUnlockSeconds` // period of time to unlock 10% of locked Narfex //

`firstNarfexPrice` // price of Narfex to buy locked tokens //

`pairAddress` // pair Narfex -> BUSD in PancakeSwap //

`NarfexAddress` // Narfex address for BUSD price //

## ***`Factory` contract***
1. `Factory` allow to all users to make pools for crowdfunding
```solidity
   function createPool(uint256 _maxAmount)
```
 you have to write `_maxAmount` variable it's a max crowdfunding amount of this pool

## ***How to participate in crowdfunding for token-sale `Narfex`***
1. `Pool` allow to all users to deposit BUSD less than minimum amount in token-sale contract
```solidity
   function depositBUSD(uint256 amount)
```
 you have to write `minUserDeposit` < `amount` < `maxUserDeposit` of deposit in this pool in BUSD

2. When `maxPoolAmount` = BUSD balance of pool and pool in whitelist of token-sale users can participate im token-sale
```solidity
   function buyNRFX()
```

3. After period of time for unlock, users in pool can use function to unlock Narfex and than withdraw
```solidity
   function unlockNRFX()
```

```solidity
   function withdrawNRFX(uint256 _amount)
```
 `_amount` Amount NRFX to withdraw

5. If `Pool` can not have enogh money to participate in token-sale, creator of `Pool` or Narfex team can use function to withdraw for all user's BUSD deposits
```
   function emergencyWithdrawBUSD()
```
 
