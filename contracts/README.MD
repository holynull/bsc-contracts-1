# Contracts Introduces for Security Audit

Main contracts:

BStablePool.sol

BStableProxyV2.sol

BStableTokenV2.sol


## BStablePool.sol

Copy from 3pool contract from curve.fi.

https://github.com/curvefi/curve-contract/blob/master/contracts/pools/3pool/StableSwap3Pool.vy

### Defference 1

Our decimal is 18.

```
uint256[] private PRECISION_MUL = [1, 1, 1];
uint256[] private RATES = [
        1000000000000000000,
        1000000000000000000,
        1000000000000000000
];
```
### Difference 2

We add an owner's address in the contructor, instead of use creator's address as owner.


## BStableProxyV2.sol

We use SushiSwap's MasterChef contract to farming our BST token.

https://github.com/sushiswap/sushiswap/blob/master/contracts/MasterChef.sol



## BStableTokenV2.sol

We use SUSHI's contract as our BST token's contract.

https://github.com/sushiswap/sushiswap/blob/master/contracts/SushiToken.sol

### Difference 1

We use an owner address and minter address in the constructor.

