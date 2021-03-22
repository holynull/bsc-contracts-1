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

    ///@notice the struct which store investors' info.
    struct InvestorInfo {
        address investorAddress;
        uint256 weight;
        address passbookAddress;
        uint256 staTime;
        uint256 endTime;
    }

    /// @notice Save investors info.
    mapping(address => InvestorInfo) public infos;

    ///@notice Store investor's address
    address[] public investorAddresses;

    ///@notice Token's address(BST)
    address public tokenAddress;

    ///@notice Invest weight.
    uint256 public totalWeight;

    ///@notice Once the tokens on this contract be distributed to investor's passbook, this contract will be locked.
    bool public locked = false;

    constructor(address owner_) public {
        transferOwnership(owner_);
    }

    ///@notice Add an investor's info.
    ///@param investorAddress_ Investor's address
    ///@param weight_ Investor's weight.
    ///@param staTime_ Investors' claiming start at.
    ///@param endTime_ Investors' claiming end at.
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

    ///@notice Set investor's info
    ///@param investorAddress_ Investor's address
    ///@param weight_ Investor's weight
    ///@param staTime_ Claiming start at.
    ///@param endTime_ Claiming end at.
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

    ///@notice Distribute assets of this contract to investor's passbook.
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

    ///@notice Burn assets of this contract.
    function burnTokens() public onlyOwner {
        require(!locked, "AMC:burnTokens:amc is locked");
        uint256 balance = IBEP20(tokenAddress).balanceOf(address(this));
        IBEP20Burnable(tokenAddress).burn(balance);
    }

    ///@notice Get investor's weight
    function getWeights() public view returns (uint256[] memory) {
        uint256[] memory weights;
        for (uint256 i = 0; i < investorAddresses.length; i++) {
            InvestorInfo storage info = infos[investorAddresses[i]];
            weights[i] = info.weight;
        }
        return weights;
    }

    ///@notice Get investor's info
    ///@param investorAddress_ Investor's address
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

    ///@notice Set asset's address
    function setTokenAddress(address tokenAddress_) public onlyOwner {
        require(
            tokenAddress == address(0),
            "AssetManagementCenter:setTokenAddress:can't change token address"
        );
        tokenAddress = tokenAddress_;
    }
}
