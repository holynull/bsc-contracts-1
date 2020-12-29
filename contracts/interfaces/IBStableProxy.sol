pragma solidity ^0.6.0;
import "../interfaces/IBEP20.sol";

interface IBStableProxy is IBEP20 {
    function getPoolInfo(uint256 _pid)
        external
        view
        returns (
            address _poolAddress,
            address[] memory _coins,
            uint256 _allocPoint,
            uint256 _accTokenPerShare,
            uint256 _shareRewardRate,
            uint256 _swapRewardRate,
            uint256 _totalVolAccPoints,
            uint256 _totalVolReward,
            uint256 _lastUpdateTime,
            uint256[] memory _data
        );

    function getTokenAddress() external view returns (address taddress);

    function getUserInfo(uint256 _pid, address user)
        external
        view
        returns (
            uint256 _amount,
            uint256 _volume,
            uint256 _rewardDebt,
            uint256 _volReward,
            uint256 _farmingReward
        );

    function getPoolUsers(uint256 _pid)
        external
        view
        returns (address[] memory _users);

    function getPoolsLength() external view returns (uint256 l);

    function getTotalAllocPoint() external view returns (uint256 r);

    function isMigrationOpen() external view returns (bool r);

    function getMigrateFrom() external view returns (address _a);

    function transferMinterTo(address to) external;

    function approveTokenTo(address nMinter) external;
}
