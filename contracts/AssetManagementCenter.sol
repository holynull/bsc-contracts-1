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

    struct InvestorInfo {
        address investorAddress;
        uint256 weight;
        address passbookAddress;
        uint256 staTime;
        uint256 endTime;
    }

    mapping(address => InvestorInfo) public infos;

    address[] public investorAddresses;

    address public tokenAddress;

    uint256 public totalWeight;

    bool public locked = false;

    constructor(address owner_) public {
        transferOwnership(owner_);
    }

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

    function distributeAsset() public onlyOwner {
        require(!locked, "AMC:distributeAsset:amc is locked");
        InvestorPassbook passbook;
        for (uint256 i = 0; i < investorAddresses.length; i++) {
            InvestorInfo storage info = infos[investorAddresses[i]];
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
                    .div(totalWeight);
            totalWeight = totalWeight.sub(info.weight);
            TransferHelper.safeTransfer(
                tokenAddress,
                info.passbookAddress,
                amt
            );
        }
        locked = true;
    }

    function burnTokens() public onlyOwner {
        require(!locked, "AMC:burnTokens:amc is locked");
        uint256 balance = IBEP20(tokenAddress).balanceOf(address(this));
        IBEP20Burnable(tokenAddress).burn(balance);
    }

    function getWeights() public view returns (uint256[] memory) {
        uint256[] memory weights;
        for (uint256 i = 0; i < investorAddresses.length; i++) {
            InvestorInfo storage info = infos[investorAddresses[i]];
            weights[i] = info.weight;
        }
        return weights;
    }

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

    function setTokenAddress(address tokenAddress_) public onlyOwner {
        tokenAddress = tokenAddress_;
    }
}
