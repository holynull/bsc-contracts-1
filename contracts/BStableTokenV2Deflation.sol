// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "./BEP20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

///@title BSTToken with Governance.
contract BStableTokenV2Deflation is
    BEP20("BStable Token", "BST"),
    BEP20Burnable,
    Ownable
{
    address public minter;

    /**
     * We design that tokenPerBlock will be reduced every year.
     * So there is a unvariable tokenPerBlock in one year, we call it a period.
     * Then it will be reduced a little in next year, and then it goes on like this.
     */

    // tokenPerBlock reduction period's index of now
    uint256 public periodIndex = 0;

    // coefficient of reduction
    uint256 public RATE_REDUCTION_COEFFICIENT = 1189207115002721024;

    // To mint tokens, block.number must bigger then this value.
    uint256 public epochBlock = 0;

    // the start block when the reduction start. It will start at when reward start launching.
    uint256 public startEpochBlock = 0;

    // It produce one block in 3 seconds on BSC, so it will produce 20 blocks in 1 minute.
    uint256 public BLOCKS_PER_MINUTE = 20;

    // blocks which will be producted in one period.
    uint256 public blocksPerPeriod = 0;

    // blocks which will be producted in one period.
    // period which dosn't have bonus.
    uint256 public blocksPerPeriodOutBonus = 0;

    // BST tokens created per block.
    uint256 public tokenPerBlock;

    // Bonus muliplier for early token makers.
    uint256 public bonusTimes = 1;

    // Block number when bonus BST period ends.
    uint256 public bonusEndBlock;

    uint256 epochSupply = 0;

    event UpdateMiningParameters(uint256 time, uint256 rate, uint256 supply);

    constructor(
        address owner,
        address minter_,
        uint256 _tokenPerBlock,
        uint256 _startEpochBlock,
        uint256 _bonusEndBlock,
        uint256 _bonusTimes,
        uint256 _periodMinutes
    ) public {
        // Aim to make tokenPerBlock reduction simply, we require bonus must be end in 1st year(period).
        // And bonus must start at _startEpochBlock
        require(
            _bonusEndBlock > _startEpochBlock &&
                _bonusEndBlock <=
                _startEpochBlock.add(_periodMinutes.mul(BLOCKS_PER_MINUTE)),
            "Bonus must end in first reduction period."
        );
        transferOwnership(owner);
        minter = minter_;
        bonusEndBlock = _bonusEndBlock;
        startEpochBlock = _startEpochBlock;
        epochBlock = _startEpochBlock;
        bonusTimes = _bonusTimes;
        blocksPerPeriodOutBonus = _periodMinutes.mul(BLOCKS_PER_MINUTE);
        // bonus goes first.
        tokenPerBlock = _tokenPerBlock.mul(bonusTimes);
        // bonus goes first.
        blocksPerPeriod = bonusEndBlock.sub(startEpochBlock);
    }

    function _updateMiningParameters() internal {
        uint256 _startEpochBlock = startEpochBlock;
        startEpochBlock = startEpochBlock.add(blocksPerPeriod);
        epochSupply = epochSupply.add(tokenPerBlock.mul(blocksPerPeriod));
        if (periodIndex == 0) {
            // bonus ends just now
            tokenPerBlock = tokenPerBlock.div(bonusTimes);
            blocksPerPeriod = _startEpochBlock.add(blocksPerPeriodOutBonus).sub(
                bonusEndBlock
            );
        } else {
            tokenPerBlock = tokenPerBlock.mul(10**18).div(
                RATE_REDUCTION_COEFFICIENT
            );
            blocksPerPeriod = blocksPerPeriodOutBonus;
        }
        periodIndex = periodIndex.add(1);
        emit UpdateMiningParameters(block.number, tokenPerBlock, epochSupply);
    }

    function updateMiningParameters() external {
        require(
            block.number >= startEpochBlock.add(blocksPerPeriod),
            "BStableTokenV2:updateMiningParameters: too soon!"
        );
        _updateMiningParameters();
    }

    function _availableSupply() internal view returns (uint256 result) {
        if (block.number >= startEpochBlock) {
            result = epochSupply.add(
                block.number.sub(startEpochBlock).mul(tokenPerBlock)
            );
        } else {
            return 0;
        }
    }

    function availableSupply() external view returns (uint256 result) {
        result = _availableSupply();
    }

    function getMaxMintableAmount() external view returns (uint256) {
        return _availableSupply().sub(totalSupply());
    }

    /// @notice Creates `_amount` token to `_to`. Must only be called by the owner (MasterChef).
    function mint(address _to, uint256 _amount) public {
        require(
            block.number >= epochBlock,
            "BStableTokenV2:mint: not start yet"
        );
        require(msg.sender == minter, "BStableTokenV2:mint: only minter.");
        if (block.number >= startEpochBlock.add(blocksPerPeriod)) {
            _updateMiningParameters();
        }
        uint256 _total_supply = totalSupply().add(_amount);
        require(
            _total_supply <= _availableSupply(),
            "BStableTokenV2:mint: exceeds allowable mint amount"
        );
        _mint(_to, _amount);
        _moveDelegates(address(0), _delegates[_to], _amount);
    }

    /// @notice A record of each accounts delegate
    mapping(address => address) internal _delegates;

    /// @notice A checkpoint for marking number of votes from a given block
    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    /// @notice A record of votes checkpoints for each account, by index
    mapping(address => mapping(uint32 => Checkpoint)) public checkpoints;

    /// @notice The number of checkpoints for each account
    mapping(address => uint32) public numCheckpoints;

    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH =
        keccak256(
            "EIP712Domain(string name,uint256 chainId,address verifyingContract)"
        );

    /// @notice The EIP-712 typehash for the delegation struct used by the contract
    bytes32 public constant DELEGATION_TYPEHASH =
        keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    /// @notice A record of states for signing / validating signatures
    mapping(address => uint256) public nonces;

    /// @notice An event thats emitted when an account changes its delegate
    event DelegateChanged(
        address indexed delegator,
        address indexed fromDelegate,
        address indexed toDelegate
    );

    /// @notice An event thats emitted when a delegate account's vote balance changes
    event DelegateVotesChanged(
        address indexed delegate,
        uint256 previousBalance,
        uint256 newBalance
    );

    /**
     * @notice Delegate votes from `msg.sender` to `delegatee`
     * @param delegator The address to get delegatee for
     */
    function delegates(address delegator) external view returns (address) {
        return _delegates[delegator];
    }

    /**
     * @notice Delegate votes from `msg.sender` to `delegatee`
     * @param delegatee The address to delegate votes to
     */
    function delegate(address delegatee) external {
        return _delegate(msg.sender, delegatee);
    }

    /**
     * @notice Delegates votes from signatory to `delegatee`
     * @param delegatee The address to delegate votes to
     * @param nonce The contract state required to match the signature
     * @param expiry The time at which to expire the signature
     * @param v The recovery byte of the signature
     * @param r Half of the ECDSA signature pair
     * @param s Half of the ECDSA signature pair
     */
    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        bytes32 domainSeparator =
            keccak256(
                abi.encode(
                    DOMAIN_TYPEHASH,
                    keccak256(bytes(name())),
                    getChainId(),
                    address(this)
                )
            );

        bytes32 structHash =
            keccak256(
                abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry)
            );

        bytes32 digest =
            keccak256(
                abi.encodePacked("\x19\x01", domainSeparator, structHash)
            );

        address signatory = ecrecover(digest, v, r, s);
        require(
            signatory != address(0),
            "BST::delegateBySig: invalid signature"
        );
        require(
            nonce == nonces[signatory]++,
            "BST::delegateBySig: invalid nonce"
        );
        require(now <= expiry, "BST::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    /**
     * @notice Gets the current votes balance for `account`
     * @param account The address to get votes balance
     * @return The number of current votes for `account`
     */
    function getCurrentVotes(address account) external view returns (uint256) {
        uint32 nCheckpoints = numCheckpoints[account];
        return
            nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    /**
     * @notice Determine the prior number of votes for an account as of a block number
     * @dev Block number must be a finalized block or else this function will revert to prevent misinformation.
     * @param account The address of the account to check
     * @param blockNumber The block number to get the vote balance at
     * @return The number of votes the account had as of the given block
     */
    function getPriorVotes(address account, uint256 blockNumber)
        external
        view
        returns (uint256)
    {
        require(
            blockNumber < block.number,
            "BST::getPriorVotes: not yet determined"
        );

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        // First check most recent balance
        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        // Next check implicit zero balance
        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee) internal {
        address currentDelegate = _delegates[delegator];
        uint256 delegatorBalance = balanceOf(delegator); // balance of underlying BSTs (not scaled);
        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(
        address srcRep,
        address dstRep,
        uint256 amount
    ) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                // decrease old representative
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld =
                    srcRepNum > 0
                        ? checkpoints[srcRep][srcRepNum - 1].votes
                        : 0;
                uint256 srcRepNew = srcRepOld.sub(amount);
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                // increase new representative
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld =
                    dstRepNum > 0
                        ? checkpoints[dstRep][dstRepNum - 1].votes
                        : 0;
                uint256 dstRepNew = dstRepOld.add(amount);
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    ) internal {
        uint32 blockNumber =
            safe32(
                block.number,
                "BST::_writeCheckpoint: block number exceeds 32 bits"
            );

        if (
            nCheckpoints > 0 &&
            checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber
        ) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(
                blockNumber,
                newVotes
            );
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint256 n, string memory errorMessage)
        internal
        pure
        returns (uint32)
    {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function getChainId() internal pure returns (uint256) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }
}
