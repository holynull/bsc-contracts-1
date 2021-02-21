pragma solidity ^0.6.0;

import "./IBEP20.sol";

// BStable DAO Token Wallet
// All data's decimal is 18.
interface IBStableTokenWallet is IBEP20 {
    function approveTokenToProxy(address tokenAddress, uint256 amt) external;
}
