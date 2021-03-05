pragma solidity ^0.6.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./lib/TransferHelper.sol";
import "./interfaces/IBEP20.sol";
import "./interfaces/IBEP20Burnable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./InvestorPassbook.sol";

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
