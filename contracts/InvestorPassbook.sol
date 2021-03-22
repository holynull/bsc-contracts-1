pragma solidity ^0.6.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./lib/TransferHelper.sol";
import "./interfaces/IBEP20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract InvestorPassbook is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    uint256 public staTime;
    uint256 public endTime;
    uint256 public lastUpdateTime;
    address public tokenAddress;

    ///@param owner_ contract's owner address
    ///@param staTime_ when claiming will start
    ///@param endTime_ when claiming will end
    ///@param tokenAddress_ tokens' address (BST)
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

    ///@notice Investors claim their tokens.
    ///@dev only woner
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
