## ***How to participate in the purchase `Narfex`***
1. Sale starts when `owner` (deployer) deploy this smart contract in mainnet, you have `timeEndSale` in seconds to participate in the `token-sale`

2. To participate in the `token-sale`, you must be authorized to buy. To do this, the owner (deployer) of the contract must add him to the `whitelist`
```solidity
    function addWhitelist(address _address)
```
   In this case, `address` is address of user, whose allowed to buy tokens.
    P.S. in testnet version you have not be in whitelist to buy
On successful execution of the function, event is generated
`AddedToWhitelist(_address)`
   

3. Then you should deposit your BUSD tokens to buy Narfex by `firstNarfexPrice` - fixed price of Narfex
```solidity
   function buyTokens(uint256 amount)
```
   `amount` it is your deposit in BUSD. Your tokens will be locked in this contract for period of time
   
On successful execution of the function, event is generated
`Sold(_msgSender, scaledAmount)`
   
4. After 60 days from `boughtTime` you have allowance to unlock tokens for the amount equivalent to the deposit in BUSD. And every 120 days after unlocking from the previous item, you can receive 10 percent of the remaining locked amount of Narfex.
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
