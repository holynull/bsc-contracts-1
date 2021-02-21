pragma solidity ^0.6.0;

import "./BEP20.sol";
import "./interfaces/IBEP20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./lib/TransferHelper.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract AssetManagementCenter is BEP20, Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    uint256 DAY = 86400;

    struct Asset {
        address assetAddress;
        uint256 releaseTime;
        address claimer;
        uint256 epochTime;
    }

    mapping(address => Asset) locks;

    constructor() public BEP20("BOW Asset Management Center", "BAMC-V1") {
        transferOwnership(msg.sender);
    }

    function addAsset(
        address assetAddress,
        uint256 epochTime,
        uint256 lockDaysFromNow
    ) public onlyOwner {
        require(locks[assetAddress].assetAddress == address(0), "asset exist");
        locks[assetAddress].assetAddress = assetAddress;
        if (epochTime < block.timestamp) {
            epochTime = block.timestamp;
        }
        locks[assetAddress].epochTime = epochTime;
        locks[assetAddress].releaseTime = epochTime.add(
            lockDaysFromNow.mul(DAY)
        );
        locks[assetAddress].claimer = msg.sender;
    }

    function setClaimer(address assetAddress, address nClaimer)
        public
        onlyOwner
    {
        require(
            locks[assetAddress].assetAddress != address(0),
            "asset no exist"
        );
        locks[assetAddress].claimer = nClaimer;
    }

    function getLock(address assetAddress)
        public
        view
        returns (
            bool isLocked,
            address _assetAddress,
            uint256 _releaseTime,
            address _claimer,
            uint256 _balance,
            uint256 _epochTime
        )
    {
        uint256 bal = IBEP20(assetAddress).balanceOf(address(this));
        return (
            locks[assetAddress].releaseTime >= block.timestamp &&
                locks[assetAddress].epochTime <= block.timestamp,
            locks[assetAddress].assetAddress,
            locks[assetAddress].releaseTime,
            locks[assetAddress].claimer,
            bal,
            locks[assetAddress].epochTime
        );
    }

    function claim(address assetAddress, uint256 amt) public nonReentrant {
        require(
            locks[assetAddress].assetAddress != address(0),
            "asset lock no exist"
        );
        require(
            locks[assetAddress].claimer == msg.sender,
            "you are not claimer"
        );
        require(
            locks[assetAddress].releaseTime < block.timestamp ||
                locks[assetAddress].epochTime > block.timestamp,
            "within a lock-in period "
        );
        uint256 bal = IBEPt20(assetAddress).balanceOf(address(this));
        require(bal >= amt, "no enough balance");
        TransferHelper.safeTransfer(assetAddress, msg.sender, amt);
    }

    function extendReleaseTime(address assetAddress, uint256 extendDays)
        public
    {
        require(
            locks[assetAddress].assetAddress != address(0),
            "asset lock no exist"
        );
        require(
            locks[assetAddress].claimer == msg.sender,
            "you are not claimer"
        );
        locks[assetAddress].releaseTime = locks[assetAddress].releaseTime.add(
            extendDays.mul(DAY)
        );
    }
}
