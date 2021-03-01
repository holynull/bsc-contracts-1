// File: @openzeppelin/contracts/GSN/Context.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/interfaces/IBEP20.sol

pragma solidity ^0.6.0;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: @openzeppelin/contracts/math/SafeMath.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: @openzeppelin/contracts/utils/Address.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.2;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// File: contracts/BEP20.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;






/**
 * @dev Implementation of the {IBEP20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {BEP20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-BEP20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of BEP20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IBEP20-approve}.
 */
contract BEP20 is Context, IBEP20 {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public override view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public override view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {BEP20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IBEP20-balanceOf} and {IBEP20-transfer}.
     */
    function decimals() public override view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IBEP20-totalSupply}.
     */
    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IBEP20-balanceOf}.
     */
    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IBEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IBEP20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        virtual
        override
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IBEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IBEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "BEP20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IBEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IBEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "BEP20: decreased allowance below zero"
            )
        );
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(
            amount,
            "BEP20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(
            amount,
            "BEP20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// File: contracts/lib/TransferHelper.sol

pragma solidity >=0.6.0;

// helper mBNBods for interacting with BEP20 tokens and sending BNB that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferBNB(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: BNB_TRANSFER_FAILED');
    }
}

// File: contracts/BStableTokenWallet.sol

pragma solidity ^0.6.0;




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

// File: contracts/interfaces/IBStablePool.sol

pragma solidity ^0.6.0;


interface IBStablePool is IBEP20 {
    function A() external view returns (uint256 A1);

    function get_virtual_price() external view returns (uint256 price);

    function calc_token_amount(uint256[] calldata amounts, bool deposit)
        external
        view
        returns (uint256 result);

    function add_liquidity(uint256[] calldata amounts, uint256 min_mint_amount)
        external;

    function get_dy(
        uint256 i,
        uint256 j,
        uint256 dx
    ) external view returns (uint256 result);

    function get_dy_underlying(
        uint256 i,
        uint256 j,
        uint256 dx
    ) external view returns (uint256 result);

    function exchange(
        uint256 i,
        uint256 j,
        uint256 dx,
        uint256 min_dy
    ) external;

    function remove_liquidity(uint256 _amount, uint256[] calldata min_amounts)
        external;

    function remove_liquidity_imbalance(
        uint256[] calldata amounts,
        uint256 max_burn_amount
    ) external;

    function calc_withdraw_one_coin(uint256 _token_amount, uint256 i)
        external
        view
        returns (uint256 result);

    function remove_liquidity_one_coin(
        uint256 _token_amount,
        uint256 i,
        uint256 min_amount
    ) external;

    function ramp_A(uint256 _future_A, uint256 _future_time) external;

    function stop_ramp_A() external;

    function commit_new_fee(uint256 new_fee, uint256 new_admin_fee) external;

    function apply_new_fee() external;

    function revert_new_parameters() external;

    function revert_transfer_ownership() external;

    function admin_balances(uint256 i) external view returns (uint256 balance);

    function withdraw_admin_fees() external;

    function donate_admin_fees() external;

    function kill_me() external;

    function unkill_me() external;

    function transferOwnership(address newOwner) external;

    function owner() external view returns (address _owner);

    function getCoins() external view returns (address[] memory);

    function getBalances() external view returns (uint256[] memory);

    function getFee() external view returns (uint256);

    function getAdminFee() external view returns (uint256);

    function getInitialA() external view returns (uint256);

    function getFutrueA() external view returns (uint256);

    function getinitialATime() external view returns (uint256);

    function getFutureATime() external view returns (uint256);

    function getKillDeadline() external view returns (uint256);

    function getVolume() external view returns (uint256);
}

// File: contracts/interfaces/IBStableProxy.sol

pragma solidity ^0.6.0;



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

    function getWallets()
        external
        view
        returns (
            BStableTokenWallet walletShare,
            BStableTokenWallet walletSwap,
            BStableTokenWallet walletLPStaking
        );
}

// File: contracts/interfaces/IBStableToken.sol

pragma solidity ^0.6.0;


interface IBStableToken is IBEP20 {
    function mint(address to, uint256 amount) external returns (bool);

    function availableSupply() external view returns (uint256 result);

    function transferMinterTo(address _minter) external;

    function getMinter() external view returns (address _minter);
}

// File: @openzeppelin/contracts/utils/ReentrancyGuard.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// File: contracts/BStableProxy.sol

pragma solidity ^0.6.0;











// Proxy
contract BStableProxy is IBStableProxy, BEP20, Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    struct PoolInfo {
        address poolAddress;
        address[] coins;
        uint256 allocPoint;
        uint256 accTokenPerShare;
        uint256 shareRewardRate; //  share reward percent of total release amount. wei
        uint256 swapRewardRate; //  swap reward percent of total release amount.  wei
        uint256 totalVolAccPoints; // total volume accumulate points. wei, 总交易积分
        uint256 totalVolReward; // total volume reword. wei 总发放的交易奖励数量
        uint256 lastUpdateTime;
    }
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 volume; // swap volume.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 volReward;
        uint256 farmingReward;
    }

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );

    // state data
    PoolInfo[] pools;
    mapping(uint256 => address[]) poolUsers;
    uint256 totalAllocPoint = 0;
    address tokenAddress;
    mapping(uint256 => mapping(address => UserInfo)) userInfo;

    bool _openMigration = false;
    address migrateFrom;

    BStableTokenWallet walletShare;
    BStableTokenWallet walletSwap;
    BStableTokenWallet walletLPStaking;

    address devAddress;
    address amcAddress;
    uint256 devPoints = 10;
    uint256 amcPoints = 15;
    uint256 communityPoints = 72;
    uint256 mintTotalPoints = 97;

    modifier noOpenMigration() {
        require(!_openMigration, "a migration is open.");
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        address _tokenAddress,
        address _amcAddress,
        address ownerAddress
    ) public BEP20(_name, _symbol) {
        tokenAddress = _tokenAddress;
        createWallet();
        devAddress = msg.sender;
        amcAddress = _amcAddress;
        transferOwnership(ownerAddress);
    }

    function getDevAddress() public view returns (address) {
        return devAddress;
    }

    function getAmcAddress() public view returns (address) {
        return amcAddress;
    }

    function createWallet() internal {
        require(
            address(walletShare) == address(0) &&
                address(walletSwap) == address(0) &&
                address(walletLPStaking) == address(0),
            "wallet not empty"
        );
        walletShare = new BStableTokenWallet(
            "BStable Token Wallet for LP farming reward",
            "BTWL",
            address(this),
            address(this)
        );
        walletSwap = new BStableTokenWallet(
            "BStable Token Wallet for LP swap reward",
            "BTWS",
            address(this),
            address(this)
        );
        walletLPStaking = new BStableTokenWallet(
            "BStable Token Wallet for LP staking",
            "BTWLP",
            address(this),
            address(this)
        );
    }

    function getWallets()
        public
        view
        override
        returns (
            BStableTokenWallet wsAddress,
            BStableTokenWallet weAddress,
            BStableTokenWallet wstakingAddress
        )
    {
        return (walletLPStaking, walletSwap, walletLPStaking);
    }

    function getPoolInfo(uint256 _pid)
        public
        view
        override
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
            uint256[] memory arrData
        )
    {
        arrData = new uint256[](7);
        _poolAddress = pools[_pid].poolAddress;
        _coins = pools[_pid].coins;
        _allocPoint = pools[_pid].allocPoint;
        arrData[0] = pools[_pid].allocPoint;
        _accTokenPerShare = pools[_pid].accTokenPerShare;
        arrData[1] = pools[_pid].accTokenPerShare;
        _shareRewardRate = pools[_pid].shareRewardRate;
        arrData[2] = pools[_pid].shareRewardRate;
        _swapRewardRate = pools[_pid].swapRewardRate;
        arrData[3] = pools[_pid].swapRewardRate;
        _totalVolAccPoints = pools[_pid].totalVolAccPoints;
        arrData[4] = pools[_pid].totalVolAccPoints;
        _totalVolReward = pools[_pid].totalVolReward;
        arrData[5] = pools[_pid].totalVolReward;
        _lastUpdateTime = pools[_pid].lastUpdateTime;
        arrData[6] = pools[_pid].lastUpdateTime;
    }

    function getTokenAddress() public view override returns (address taddress) {
        taddress = tokenAddress;
    }

    function getUserInfo(uint256 _pid, address user)
        public
        view
        override
        returns (
            uint256 _amount,
            uint256 _volume,
            uint256 _rewardDebt,
            uint256 _volReward,
            uint256 _farmingReward
        )
    {
        _amount = userInfo[_pid][user].amount;
        _volume = userInfo[_pid][user].volume;
        _rewardDebt = userInfo[_pid][user].rewardDebt;
        _volReward = userInfo[_pid][user].volReward;
        _farmingReward = userInfo[_pid][user].farmingReward;
    }

    function getPoolUsers(uint256 _pid)
        public
        view
        override
        returns (address[] memory _users)
    {
        _users = poolUsers[_pid];
    }

    function getPoolsLength() public view override returns (uint256 l) {
        l = pools.length;
    }

    function getTotalAllocPoint() public view override returns (uint256 r) {
        r = totalAllocPoint;
    }

    function isMigrationOpen() external view override returns (bool r) {
        r = _openMigration;
    }

    function getMigrateFrom() public view override returns (address _a) {
        _a = migrateFrom;
    }

    function exchange(
        uint256 _pid,
        uint256 i,
        uint256 j,
        uint256 dx,
        uint256 min_dy
    ) external nonReentrant noOpenMigration {
        require(
            pools[_pid].poolAddress != address(0),
            "address(0) can't be a pool"
        );
        bool exists = false;
        for (uint256 index = 0; index < poolUsers[_pid].length; index++) {
            if (poolUsers[_pid][index] == msg.sender) {
                exists = true;
                break;
            }
        }
        if (!exists) {
            poolUsers[_pid].push(msg.sender);
        }
        updatePool(_pid);
        uint256 bali = IBEP20(pools[_pid].coins[i]).balanceOf(address(this));
        TransferHelper.safeTransferFrom(
            pools[_pid].coins[i],
            msg.sender,
            address(this),
            dx
        );
        dx = IBEP20(pools[_pid].coins[i]).balanceOf(address(this)).sub(bali);
        TransferHelper.safeApprove(
            pools[_pid].coins[i],
            pools[_pid].poolAddress,
            dx
        );
        uint256 balj = IBEP20(pools[_pid].coins[j]).balanceOf(address(this));
        IBStablePool(pools[_pid].poolAddress).exchange(i, j, dx, min_dy);
        uint256 dy =
            IBEP20(pools[_pid].coins[j]).balanceOf(address(this)).sub(balj);
        require(dy > 0, "no coin out");
        userInfo[_pid][msg.sender].volume = userInfo[_pid][msg.sender]
            .volume
            .add(dy.mul(dy).div(dx));
        require(dy.mul(dy).div(dx) > 0, "accumulate points is 0");
        uint256 tokenAmt = IBEP20(tokenAddress).balanceOf(address(walletSwap));
        uint256 rewardAmt;
        if (
            pools[_pid].totalVolAccPoints > 0 && pools[_pid].totalVolReward > 0
        ) {
            rewardAmt = pools[_pid].totalVolReward.mul(dy.mul(dy).div(dx)).div(
                pools[_pid].totalVolAccPoints
            );
        } else {
            rewardAmt = tokenAmt.div(10);
        }
        if (rewardAmt > tokenAmt) {
            userInfo[_pid][msg.sender].volReward = userInfo[_pid][msg.sender]
                .volReward
                .add(tokenAmt);
            pools[_pid].totalVolReward = pools[_pid].totalVolReward.add(
                tokenAmt
            );
            walletSwap.approveTokenToProxy(tokenAddress, tokenAmt);
            TransferHelper.safeTransferFrom(
                tokenAddress,
                address(walletSwap),
                msg.sender,
                tokenAmt
            );
        } else {
            userInfo[_pid][msg.sender].volReward = userInfo[_pid][msg.sender]
                .volReward
                .add(rewardAmt);
            pools[_pid].totalVolReward = pools[_pid].totalVolReward.add(
                rewardAmt
            );
            walletSwap.approveTokenToProxy(tokenAddress, rewardAmt);
            TransferHelper.safeTransferFrom(
                tokenAddress,
                address(walletSwap),
                msg.sender,
                rewardAmt
            );
        }
        pools[_pid].totalVolAccPoints = pools[_pid].totalVolAccPoints.add(
            dy.mul(dy).div(dx)
        );
        TransferHelper.safeTransfer(pools[_pid].coins[j], msg.sender, dy);
    }

    function getPoolAddress(uint256 _pid)
        external
        view
        noOpenMigration
        returns (address _poolAddress)
    {
        _poolAddress = pools[_pid].poolAddress;
    }

    function pendingReward(uint256 _pid, address _user)
        external
        view
        noOpenMigration
        returns (uint256)
    {
        PoolInfo storage pool = pools[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accSushiPerShare = pool.accTokenPerShare;
        uint256 lpSupply =
            IBEP20(pool.poolAddress).balanceOf(address(walletLPStaking));
        if (lpSupply != 0) {
            uint256 releaseAmt =
                IBStableToken(tokenAddress).availableSupply().sub(
                    IBStableToken(tokenAddress).totalSupply()
                );
            uint256 reward =
                releaseAmt
                    .mul(pool.shareRewardRate)
                    .div(10**18)
                    .mul(pool.allocPoint)
                    .div(totalAllocPoint);
            accSushiPerShare = accSushiPerShare.add(
                reward.mul(10**18).div(lpSupply)
            );
        }
        uint256 pending =
            user.amount.mul(accSushiPerShare).div(10**18).sub(user.rewardDebt);
        return pending;
    }

    function massUpdatePools() external noOpenMigration {
        uint256 length = pools.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public noOpenMigration {
        PoolInfo storage pool = pools[_pid];
        if (block.timestamp <= pool.lastUpdateTime) {
            return;
        }
        uint256 lpSupply =
            IBEP20(pool.poolAddress).balanceOf(address(walletLPStaking));
        if (lpSupply == 0) {
            pool.lastUpdateTime = block.timestamp;
            return;
        }
        uint256 releaseAmt =
            IBStableToken(tokenAddress).availableSupply().sub(
                IBStableToken(tokenAddress).totalSupply()
            );
        uint256 mintAmt = releaseAmt.mul(pool.allocPoint).div(totalAllocPoint);
        uint256 rewardTotal = mintAmt.mul(communityPoints).div(mintTotalPoints);
        uint256 devAmt = mintAmt.mul(devPoints).div(mintTotalPoints);
        uint256 amcAmt = mintAmt.mul(amcPoints).div(mintTotalPoints);
        uint256 rewardShare = rewardTotal.mul(pool.shareRewardRate).div(10**18);
        uint256 rewardSwap = rewardTotal.mul(pool.swapRewardRate).div(10**18);
        IBStableToken(tokenAddress).mint(devAddress, devAmt.sub(1));
        IBStableToken(tokenAddress).mint(amcAddress, amcAmt.sub(1));
        IBStableToken(tokenAddress).mint(
            address(walletShare),
            rewardShare.sub(1)
        );
        IBStableToken(tokenAddress).mint(
            address(walletSwap),
            rewardSwap.sub(1)
        );
        pool.accTokenPerShare = pool.accTokenPerShare.add(
            rewardShare.mul(10**18).div(lpSupply)
        );
        pool.lastUpdateTime = block.timestamp;
    }

    function deposit(uint256 _pid, uint256 _amount) external noOpenMigration {
        UserInfo storage user = userInfo[_pid][msg.sender];
        bool exists = false;
        for (uint256 i = 0; i < poolUsers[_pid].length; i++) {
            if (poolUsers[_pid][i] == msg.sender) {
                exists = true;
                break;
            }
        }
        if (!exists) {
            poolUsers[_pid].push(msg.sender);
        }
        updatePool(_pid);
        PoolInfo storage pool = pools[_pid];
        if (user.amount > 0) {
            uint256 pending =
                user.amount.mul(pool.accTokenPerShare).div(10**18).sub(
                    user.rewardDebt
                );
            if (pending > 0) {
                uint256 tokenBal =
                    IBEP20(tokenAddress).balanceOf(address(walletShare));
                if (tokenBal >= pending) {
                    userInfo[_pid][msg.sender].farmingReward = userInfo[_pid][
                        msg.sender
                    ]
                        .farmingReward
                        .add(pending);
                    walletShare.approveTokenToProxy(tokenAddress, pending);
                    TransferHelper.safeTransferFrom(
                        tokenAddress,
                        address(walletShare),
                        msg.sender,
                        pending
                    );
                } else {
                    userInfo[_pid][msg.sender].farmingReward = userInfo[_pid][
                        msg.sender
                    ]
                        .farmingReward
                        .add(tokenBal);
                    walletShare.approveTokenToProxy(tokenAddress, tokenBal);
                    TransferHelper.safeTransferFrom(
                        tokenAddress,
                        address(walletShare),
                        msg.sender,
                        tokenBal
                    );
                }
            }
        }
        if (_amount > 0) {
            uint256 lpBal =
                IBEP20(pool.poolAddress).balanceOf(address(walletLPStaking));
            TransferHelper.safeTransferFrom(
                pool.poolAddress,
                msg.sender,
                address(walletLPStaking),
                _amount
            );
            _amount = IBEP20(pool.poolAddress)
                .balanceOf(address(walletLPStaking))
                .sub(lpBal);
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(10**18);
        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) external noOpenMigration {
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        PoolInfo storage pool = pools[_pid];
        uint256 pending =
            user.amount.mul(pool.accTokenPerShare).div(10**18).sub(
                user.rewardDebt
            );
        if (pending > 0) {
            uint256 tokenBal =
                IBEP20(tokenAddress).balanceOf(address(walletShare));
            if (tokenBal >= pending) {
                userInfo[_pid][msg.sender].farmingReward = userInfo[_pid][
                    msg.sender
                ]
                    .farmingReward
                    .add(pending);
                walletShare.approveTokenToProxy(tokenAddress, pending);
                TransferHelper.safeTransferFrom(
                    tokenAddress,
                    address(walletShare),
                    msg.sender,
                    pending
                );
            } else {
                userInfo[_pid][msg.sender].farmingReward = userInfo[_pid][
                    msg.sender
                ]
                    .farmingReward
                    .add(tokenBal);
                walletShare.approveTokenToProxy(tokenAddress, tokenBal);
                TransferHelper.safeTransferFrom(
                    tokenAddress,
                    address(walletShare),
                    msg.sender,
                    tokenBal
                );
            }
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            walletLPStaking.approveTokenToProxy(pool.poolAddress, _amount);
            TransferHelper.safeTransferFrom(
                pool.poolAddress,
                address(walletLPStaking),
                address(msg.sender),
                _amount
            );
        }
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(10**18);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function emergencyWithdraw(uint256 _pid) external {
        PoolInfo storage pool = pools[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        walletLPStaking.approveTokenToProxy(pool.poolAddress, amount);
        TransferHelper.safeTransferFrom(
            pool.poolAddress,
            address(walletLPStaking),
            address(msg.sender),
            amount
        );
        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    function openMigration() external onlyOwner {
        _openMigration = true;
    }

    function closeMigration() external onlyOwner {
        _openMigration = false;
    }

    function addPool(
        address _poolAddress,
        address[] calldata _coins,
        uint256 _allocPoint
    ) external onlyOwner {
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        pools.push(
            PoolInfo({
                poolAddress: _poolAddress,
                coins: _coins,
                allocPoint: _allocPoint,
                accTokenPerShare: 0,
                shareRewardRate: 500_000_000_000_000_000,
                swapRewardRate: 500_000_000_000_000_000,
                totalVolAccPoints: 0,
                totalVolReward: 0,
                lastUpdateTime: block.timestamp
            })
        );
    }

    function setPoolRewardRate(
        uint256 _pid,
        uint256 shareRate,
        uint256 swapRate
    ) external onlyOwner {
        require(
            shareRate.add(swapRate) <= 1_000_000_000_000_000_000,
            "sum rate lower then 100%"
        );
        pools[_pid].shareRewardRate = shareRate;
        pools[_pid].swapRewardRate = swapRate;
    }

    function setPoolCoins(uint256 _pid, address[] calldata _coins)
        external
        onlyOwner
    {
        pools[_pid].coins = _coins;
    }

    function setPoolAllocPoint(uint256 _pid, uint256 _allocPoint)
        external
        onlyOwner
    {
        totalAllocPoint = totalAllocPoint.sub(pools[_pid].allocPoint).add(
            _allocPoint
        );
        pools[_pid].allocPoint = _allocPoint;
    }

    function migratePoolInfo(IBStableProxy from) internal {
        address _poolAddress;
        address[] memory _coins;
        uint256[] memory _data;
        for (uint256 pid = 0; pid < from.getPoolsLength(); pid++) {
            (_poolAddress, _coins, , , , , , , , _data) = from.getPoolInfo(pid);
            totalAllocPoint = totalAllocPoint.add(_data[0]);
            pools.push(
                PoolInfo({
                    poolAddress: _poolAddress,
                    coins: _coins,
                    allocPoint: _data[0],
                    accTokenPerShare: _data[1],
                    shareRewardRate: _data[2],
                    swapRewardRate: _data[3],
                    totalVolAccPoints: _data[4],
                    totalVolReward: _data[5],
                    lastUpdateTime: _data[6]
                })
            );
        }
    }

    function transferMinterTo(address to) external override onlyOwner {
        require(_openMigration, "on allow when migration is open");
        IBStableToken(tokenAddress).transferMinterTo(to);
    }

    function approveTokenTo(address nMinter) external override onlyOwner {
        IBStableToken token = IBStableToken(tokenAddress);
        require(
            token.getMinter() == nMinter,
            "only allow to approve token to a minter."
        );
        uint256 balance = token.balanceOf(address(this));
        TransferHelper.safeApprove(tokenAddress, nMinter, balance);
    }

    function migrate(address _from) external onlyOwner {
        _openMigration = true;
        IBStableProxy from = IBStableProxy(_from);
        require(from.isMigrationOpen(), "from's migration not open.");
        require(migrateFrom == address(0), "migration only once.");
        migratePoolInfo(from);
        // tokenAddress = from.getTokenAddress();
        // uint256 tokenBal = IBEP20(tokenAddress).balanceOf(_from);
        // TransferHelper.safeTransferFrom(
        //     tokenAddress,
        //     _from,
        //     address(this),
        //     tokenBal
        // );

        migrateFrom = _from;
    }

    function setDevAddress(address nDevAddress) public onlyOwner {
        devAddress = nDevAddress;
    }

    function setAmcAddress(address nAmcAddress) public onlyOwner {
        amcAddress = nAmcAddress;
    }

    function setAllocPoints(
        uint256 _devPoints,
        uint256 _amcPoints,
        uint256 _communityPoints,
        uint256 _totalPoints
    ) public onlyOwner {
        devPoints = _devPoints;
        amcPoints = _amcPoints;
        communityPoints = _communityPoints;
        mintTotalPoints = _totalPoints;
    }
}
