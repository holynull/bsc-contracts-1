pragma solidity ^0.6.0;
import "../interfaces/IBEP20.sol";

interface IBStableToken {
    function transferMinterTo(address _minter) external;
}
