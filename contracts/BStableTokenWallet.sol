pragma solidity ^0.6.0;

import "./BEP20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./lib/TransferHelper.sol";

// BStable DAO Token Wallet
// All data's decimal is 18.
contract BStableTokenWallet is BEP20, Ownable {
    using SafeMath for uint256;

    address proxyAddress;

    event ApproveToProxy(address tokenAddress, address spender, uint256 amt);

    constructor(
        string memory _name,
        string memory _symbol,
        address _proxyAddress,
        address ownerAddress
    ) public BEP20(_name, _symbol) {
        transferOwnership(ownerAddress);
        proxyAddress = _proxyAddress;
    }

    function approveTokenToProxy(address tokenAddress, uint256 amt)
        public
        onlyOwner
    {
        require(msg.sender == proxyAddress, "only proxy can do this");
        TransferHelper.safeApprove(tokenAddress, proxyAddress, amt);
        emit ApproveToProxy(tokenAddress, proxyAddress, amt);
    }
}
