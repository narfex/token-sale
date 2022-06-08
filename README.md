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

## ***To unlocking Narfex after 60 days***
1. We using price in BUSD from `PancakeFactory`
```solidity
   function getUSDPrice(address _token)
```
    In this case, `_token` is address of Narfex, in PancakeFactory.
    
## ***Variables in contract***

`tokenContract`  // IBEP20 the token being sold
`busdAddress` // IBEP20 payment token address
`owner` // deployer of contract 
`saleSupply` // the number of tokens available for purchase 
`timeStartSale` // starting sale point
`timeEndSale` // period of time in seconds for private sale for whitelist users
`minAmountForUser` // minimum amount of deposit in busd to buy for each user
`maxAmountForUser` // maximum amount of deposit in busd for each user
`saleStarted` // from this point sale is started
`firstUnlock` // period of time for unlock 100% BUSD price
`percantageUnlock` // period of time to unlock 10% of locked Narfex
`firstNarfexPrice` // price of Narfex to buy locked tokens
`pairAddress` // pair Narfex -> BUSD in PancakeSwap
`NarfexAddress` // Narfex address for BUSD price
`BUSD` // BUSD address in current network
