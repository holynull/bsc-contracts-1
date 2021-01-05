pragma solidity ^0.6.0;

import "./BEP20.sol";
import "./interfaces/IBStableToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// BStable DAO Token
// All data's decimal is 18.
contract BStableToken is IBStableToken, BEP20, Ownable {
    using SafeMath for uint256;
    address minter;

    uint256 YEAR = uint256(86400).mul(365);
    uint256 INITIAL_SUPPLY = uint256(40_000_000).mul(10**18);
    uint256 INITIAL_RATE = uint256(19_092_430).mul(10**18).div(YEAR);
    uint256 RATE_REDUCTION_TIME = YEAR;
    uint256 RATE_REDUCTION_COEFFICIENT = 1189207115002721024;
    uint256 INFLATION_DELAY = 86400;

    int128 mining_epoch;
    uint256 start_epoch_time;
    uint256 rate;

    uint256 start_epoch_supply;

    event UpdateMiningParameters(uint256 time, uint256 rate, uint256 supply);

    event SetMinter(address minter);

    constructor(string memory _name, string memory _symbol)
        public
        BEP20(_name, _symbol)
    {
        transferOwnership(msg.sender);
        _mint(msg.sender, INITIAL_SUPPLY);
        start_epoch_time = block.timestamp.add(INFLATION_DELAY).sub(
            RATE_REDUCTION_TIME
        );
        mining_epoch = -1;
        rate = 0;
        start_epoch_supply = INITIAL_SUPPLY;
    }

    function getRate() public view returns (uint256 _rate) {
        _rate = rate;
    }

    function getMiningEpoch() public view returns (int128 r) {
        r = mining_epoch;
    }

    function startEpochSupply() public view returns (uint256 _supply) {
        _supply = start_epoch_supply;
    }

    function startEpochTime() public view returns (uint256 _time) {
        _time = start_epoch_time;
    }

    function _updateMiningParameters() internal {
        uint256 _rate = rate;
        uint256 _start_epoch_supply = start_epoch_supply;

        start_epoch_time = start_epoch_time.add(RATE_REDUCTION_TIME);
        mining_epoch = mining_epoch + 1;

        if (_rate == 0) {
            _rate = INITIAL_RATE;
        } else {
            _start_epoch_supply = _start_epoch_supply.add(
                _rate.mul(RATE_REDUCTION_TIME)
            );
            start_epoch_supply = _start_epoch_supply;
            _rate = _rate.mul(10**18).div(RATE_REDUCTION_COEFFICIENT);
        }
        rate = _rate;
        emit UpdateMiningParameters(
            block.timestamp,
            _rate,
            _start_epoch_supply
        );
    }

    function updateMiningParameters() external {
        require(
            block.timestamp >= start_epoch_time.add(RATE_REDUCTION_TIME),
            "# dev: too soon!"
        );
        _updateMiningParameters();
    }

    function startEpochTimeWrite()
        external
        returns (uint256 _start_epoch_time)
    {
        if (block.timestamp >= start_epoch_time.add(RATE_REDUCTION_TIME)) {
            _updateMiningParameters();
        }
        _start_epoch_time = start_epoch_time;
    }

    function futureEpochTimeWrite() external returns (uint256 result) {
        uint256 _start_epoch_time = start_epoch_time;
        if (block.timestamp >= _start_epoch_time.add(RATE_REDUCTION_TIME)) {
            _updateMiningParameters();
            result = start_epoch_time.add(RATE_REDUCTION_TIME);
        } else {
            result = _start_epoch_time.add(RATE_REDUCTION_TIME);
        }
    }

    function _availableSupply() internal view returns (uint256 result) {
        result = start_epoch_supply.add(
            block.timestamp.sub(start_epoch_time).mul(rate)
        );
    }

    function availableSupply() external view override returns (uint256 result) {
        result = _availableSupply();
    }

    function mintableInTimeframe(uint256 start, uint256 end)
        external
        view
        returns (uint256 to_mint)
    {
        require(start <= end, "# dev: start > end");
        to_mint = 0;
        uint256 current_epoch_time = start_epoch_time;
        uint256 current_rate = rate;
        if (end > current_epoch_time.add(RATE_REDUCTION_TIME)) {
            current_epoch_time = current_epoch_time.add(RATE_REDUCTION_TIME);
            current_rate = current_rate.mul(10**18).div(
                RATE_REDUCTION_COEFFICIENT
            );
        }

        require(
            end <= current_epoch_time.add(RATE_REDUCTION_TIME),
            "# dev: too far in future"
        );

        for (uint256 i = 0; i < 1000; i++) {
            if (end >= current_epoch_time) {
                uint256 current_end = end;
                if (current_end > current_epoch_time.add(RATE_REDUCTION_TIME)) {
                    current_end = current_epoch_time.add(RATE_REDUCTION_TIME);
                }
                uint256 current_start = start;
                if (
                    current_start >= current_epoch_time.add(RATE_REDUCTION_TIME)
                ) {
                    break;
                } else if (current_start < current_epoch_time) {
                    current_start = current_epoch_time;
                }
                to_mint = to_mint.add(
                    current_rate.mul(current_end.sub(current_start))
                );
                if (start >= current_epoch_time) {
                    break;
                }
            }

            current_epoch_time = current_epoch_time.sub(RATE_REDUCTION_TIME);
            current_rate = current_rate.mul(RATE_REDUCTION_COEFFICIENT).div(
                10**18
            );
            require(
                current_rate <= INITIAL_RATE,
                "  # This should never happen"
            );
        }
    }

    function setMinter(address _minter) external onlyOwner {
        require(
            minter == address(0),
            "  # dev: can set the minter only once, at creation"
        );
        require(_minter != address(0), "address(0) can't be minter");
        minter = _minter;
        emit SetMinter(_minter);
    }

    function transferMinterTo(address _minter) external override {
        require(msg.sender == minter, "only minter can transfer minter");
        require(_minter != address(0), "address(0) can't be minter");
        minter = _minter;
        emit SetMinter(_minter);
    }

    function getMinter() external view override returns (address _minter) {
        _minter = minter;
    }

    function mint(address _to, uint256 _value)
        external
        override
        returns (bool r)
    {
        if (mining_epoch < 4) {
            require(msg.sender == minter, "# dev: minter only");
            require(_to != address(0), " # dev: zero address");

            if (block.timestamp >= start_epoch_time.add(RATE_REDUCTION_TIME)) {
                _updateMiningParameters();
            }
            uint256 _total_supply = totalSupply().add(_value);
            require(
                _total_supply <= _availableSupply(),
                "# dev: exceeds allowable mint amount"
            );
            _mint(_to, _value);
            r = true;
        } else {
            r = false;
        }
    }
}
