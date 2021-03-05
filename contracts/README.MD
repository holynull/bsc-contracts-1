# 主要合约说明
主要合约包括：

BStablePool.sol

BStableProxyV2.sol

BStableTokenV2.sol

AssetManagementCenter.sol

InvestorPassbook.sol

## BStablePool.sol

参考curve的3pool合约。主要实现3种价格1:1:1的稳定币的兑换。AMM算法完全与curve的3pool合约的算法一致。

https://github.com/curvefi/curve-contract/blob/master/contracts/pools/3pool/StableSwap3Pool.vy

### 不同点一
3种币默认decimal为18.体现在下面两个参数

```
uint256[] private PRECISION_MUL = [1, 1, 1];
uint256[] private RATES = [
        1000000000000000000,
        1000000000000000000,
        1000000000000000000
];
```
### 不同点二

构造函数中增加了`ownerAddress`参数，主要实现在部署时，将`owner`地址指向安全的管理地址，而不是使用合约的创建者地址做为`owner`。


## BStableProxyV2.sol

参考sushi项目的MasterChef合约。合约主要实现，用户存入BStablePool创建的兑换池的LP，然后获得代币奖励的功能。

https://github.com/sushiswap/sushiswap/blob/master/contracts/MasterChef.sol



## BStableTokenV2.sol

项目代币BST的合约，完全参考SUSHI的代币合约。

https://github.com/sushiswap/sushiswap/blob/master/contracts/SushiToken.sol

### 不同点一

构造函数中，必须指定`owner`、`minter`和`amc`地址。`amc`是指一个资产管理合约，参见之后的说明`AssetManagementCenter`。

### 不同点二

构造函数中，如果指定了`amc`地址，那么会事先预铸`INITIAL_SUPPLY`数量个币，给`amc`地址。

## AssetManagementCenter.sol

该合约主要记录投资人地址数据。包括投资人地址；投资人地址所占的投资比重值；投资人地址可以索取代币的开始时间和结束时间。并通过一个函数，按照这些预先配置的参数，将该合约地址上的代币分配到投资地址的`Passbook`上。然后投资人，就可以在规定的时间内，逐渐的索取代币。

```
contract AssetManagementCenter is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    // 存放投资人信息的结构体
    struct InvestorInfo {
        address investorAddress;
        uint256 weight;
        address passbookAddress;
        uint256 staTime;
        uint256 endTime;
    }

    // 所有投资人的数据，key为投资人地址
    mapping(address => InvestorInfo) public infos;

    // 所有投资人的地址
    address[] public investorAddresses;

    // 项目地址的地址，投资人将获得此代币
    address public tokenAddress;

    // 整数，投资人投资比重值的和
    uint256 public totalWeight;

    // 一旦合约上的代币，分配到投资人的passbook后，此合约将被锁定。不能再进行设置更改
    bool public locked = false;

    constructor(address owner_) public {
        transferOwnership(owner_);
    }

    // 添加投资人信息，投资人的地址，所占比重，索取开始时间，索取的结束时间
    function addInvestorInfo(
        address investorAddress_,
        uint256 weight_,
        uint256 staTime_,
        uint256 endTime_
    ) public onlyOwner {
        require(
            investorAddress_ != address(0),
            "AMC:addInvestorInfo:investor is address(0)"
        );
        require(!locked, "AMC:addInvestorInfo:amc is locked");
        InvestorInfo memory info =
            InvestorInfo({
                investorAddress: investorAddress_,
                weight: weight_,
                staTime: staTime_,
                endTime: endTime_,
                passbookAddress: address(0)
            });
        infos[investorAddress_] = info;
        investorAddresses.push(investorAddress_);
        totalWeight = totalWeight.add(weight_);
    }

    // 设置投资人信息，投资人的地址，所占比重，索取开始时间，索取的结束时间
    // 只能在合约锁定前设置
    function setInvestorInfo(
        address investorAddress_,
        uint256 weight_,
        uint256 staTime_,
        uint256 endTime_
    ) public onlyOwner {
        require(
            investorAddress_ != address(0),
            "AMC:addInvestorInfo:investor is address(0)"
        );
        require(!locked, "AMC:setInvestorInfo:amc is locked");
        InvestorInfo storage info = infos[investorAddress_];
        require(
            info.investorAddress != address(0),
            "AMC:setInvestorInfo:investor not exists."
        );
        totalWeight = totalWeight.sub(info.weight);
        info.weight = weight_;
        totalWeight = totalWeight.add(weight_);
        info.staTime = staTime_;
        info.endTime = endTime_;
    }

    // 按照之前配置的投资人信息，分配合约上的代币到投资人的passbook上
    function distributeAsset() public onlyOwner {
        require(!locked, "AMC:distributeAsset:amc is locked");
        InvestorPassbook passbook;
        uint256 totalWeight_ = totalWeight;
        for (uint256 i = 0; i < investorAddresses.length; i++) {
            InvestorInfo storage info = infos[investorAddresses[i]];
            // 创建投资人的passbook
            passbook = new InvestorPassbook(
                investorAddresses[i],
                info.staTime,
                info.endTime,
                tokenAddress
            );
            info.passbookAddress = address(passbook);
            uint256 amt =
                IBEP20(tokenAddress)
                    .balanceOf(address(this))
                    .mul(info.weight)
                    .div(totalWeight_);
            totalWeight_ = totalWeight_.sub(info.weight);
            TransferHelper.safeTransfer(
                tokenAddress,
                info.passbookAddress,
                amt
            );
        }
        locked = true;
    }

    // 销毁合约上待分配的代币
    function burnTokens() public onlyOwner {
        require(!locked, "AMC:burnTokens:amc is locked");
        uint256 balance = IBEP20(tokenAddress).balanceOf(address(this));
        IBEP20Burnable(tokenAddress).burn(balance);
    }

    // 获取投资人的投资比重值
    function getWeights() public view returns (uint256[] memory) {
        uint256[] memory weights;
        for (uint256 i = 0; i < investorAddresses.length; i++) {
            InvestorInfo storage info = infos[investorAddresses[i]];
            weights[i] = info.weight;
        }
        return weights;
    }

    // 获取投资人的投资数据
    function getInvestorInfo(address investorAddress_)
        public
        view
        returns (
            uint256 staTime_,
            uint256 endTime_,
            uint256 weight_,
            address passbook_
        )
    {
        InvestorInfo storage info = infos[investorAddress_];
        investorAddress_ = info.investorAddress;
        staTime_ = info.staTime;
        endTime_ = info.endTime;
        weight_ = info.weight;
        passbook_ = info.passbookAddress;
    }

    // 设置代币合约的地址；在部署以后，需要立即设置；并且之后不能修改；
    function setTokenAddress(address tokenAddress_) public onlyOwner {
        require(
            tokenAddress == address(0),
            "AssetManagementCenter:setTokenAddress:can't change token address"
        );
        tokenAddress = tokenAddress_;
    }
}
```

## InvestorPassbook.sol

投资者的Passbook。用来存放投资者分配到的代币。然后，由该passbook的所有者，在允许的时间范围内，将代币逐渐的提走。

代码及说明：

```
contract InvestorPassbook is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    uint256 public staTime;
    uint256 public endTime;
    uint256 public lastUpdateTime;
    address public tokenAddress;

    // 参数：passbook的所有者，索取代币的开始时间，索取代币的结束时间，代币地址
    constructor(
        address owner_,
        uint256 staTime_,
        uint256 endTime_,
        address tokenAddress_
    ) public {
        transferOwnership(owner_);
        staTime = staTime_;
        endTime = endTime_;
        lastUpdateTime = staTime_;
        tokenAddress = tokenAddress_;
    }

    // 索取代币。只能有passbook的所有者索取。
    function claim() public onlyOwner nonReentrant {
        require(
            block.timestamp >= staTime,
            "InvestorPassbook:claim:not start yet"
        );
        uint256 balance = IBEP20(tokenAddress).balanceOf(address(this));
        if (block.timestamp >= staTime && block.timestamp <= endTime) {
            uint256 amt =
                balance.mul(block.timestamp.sub(lastUpdateTime)).div(
                    endTime.sub(staTime)
                );
            TransferHelper.safeTransfer(tokenAddress, msg.sender, amt);
        } else if (block.timestamp > endTime) {
            TransferHelper.safeTransfer(tokenAddress, msg.sender, balance);
        }
    }
}

```


