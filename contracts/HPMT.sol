// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

pragma solidity ^0.8.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

pragma solidity ^0.8.0;

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

pragma solidity ^0.8.0;

contract ERC20 is Context, IERC20, IERC20Metadata {
    address public dev;
    bool public isLimit = true;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        dev = msg.sender;
    }

    function cancleLimit() public {
        require(msg.sender == dev);
        isLimit = false;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (isLimit && from != dev) {
            require(amount <= 200000 ether);
        }

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

pragma solidity ^0.8.0;

abstract contract ERC20Burnable is Context, ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}

pragma solidity ^0.8.0;

abstract contract ERC20Capped is Context, ERC20 {
    uint256 private immutable _cap;

    error ERC20ExceededCap(uint256 increasedSupply, uint256 cap);
    error ERC20InvalidCap(uint256 cap);

    constructor(uint256 cap_) {
        if (cap_ == 0) {
            revert ERC20InvalidCap(0);
        }
        _cap = cap_;
    }

    function cap() public view virtual returns (uint256) {
        return _cap;
    }

    function _update(address from, address to, uint256 value) internal virtual {
        _update(from, to, value);
    }
}

pragma solidity ^0.8.0;

contract HPMT is ERC20, ERC20Burnable, Ownable, ERC20Capped {
    uint256 public userRewardMintedSupply;
    uint256 public creatorRewardMintedSupply;
    uint256 public userReward;
    uint256 public creatorReward;
    uint256 public totalWatchSeconds;
    uint256 public counter;
    mapping(address => bool) public isUserDurationLimitReached; //mapping to track users watch status
    mapping(address => uint256) public userWatchDuration; //mapping to track users watch minutes
    mapping(address => uint256) public userCurrentHalving; //mapping to track the current halving counter
    mapping(uint => address) public creatorOfTheVideo; //mapping to track the video and its creator

    constructor()
        ERC20("Hippie Pepe", "HPMT")
        ERC20Capped(17922656250 * (10 ** decimals()))
    {
        mint(_msgSender(), 2692089844); //userAmount = 15% (for team - 5% and development - 10%)
        userReward = 50 * (10 ** decimals());
        creatorReward = 97656250000000000;
    }

    // function to distriibute tokens
    function distributeTokens(
        address distributionWallet,
        uint supply
    ) external onlyOwner {
        require(supply <= balanceOf(_msgSender()), "Insufficient balance");
        _transfer(
            _msgSender(),
            distributionWallet,
            (supply * (10 ** decimals()))
        );
    }

    function mint(
        address account,
        uint256 userAmount
    ) public onlyOwner returns (bool) {
        require(
            ERC20.totalSupply() + (userAmount * 10 ** decimals()) <= cap(),
            "ERC20Capped: cap exceeded"
        );
        _mint(account, (userAmount * 10 ** decimals()));
        return true;
    }

    function uploadVideo(uint videoID) public {
        creatorOfTheVideo[videoID] = _msgSender();
    }

    function halving() private {
        require(
            totalWatchSeconds >= 18000000,
            "Halving occurs only after 18000000 seconds of watch time"
        );
        require(counter < 9, "Total halving limit reached");
        counter++;
        totalWatchSeconds = 0;
        userReward /= 2;
        creatorReward *= 2;
    }

    // function to check the cooling period of a user
    function coolingPeriodCheck() public view returns (bool) {
        return isUserDurationLimitReached[_msgSender()];
    }

    function mintWithWatchTime(
        uint[] memory arrOfWatchTime,
        uint[] memory arrOfVideos
    ) external {
        require(
            arrOfWatchTime.length == arrOfVideos.length,
            "The Array lengths can't be different"
        );
        if (userCurrentHalving[_msgSender()] != counter) {
            isUserDurationLimitReached[_msgSender()] = false;
        }
        require(!coolingPeriodCheck(), "User Cooldown time has not expired");
        uint timeSpentInSeconds = 0;
        uint totalTime = 0;
        // adding all watch time in an array to timeSpentInSeconds
        for (uint i = 0; i < arrOfWatchTime.length; i++) {
            timeSpentInSeconds += arrOfWatchTime[i];
            totalTime += arrOfWatchTime[i];
        }
        // Calculating time spent in seconds
        if (
            timeSpentInSeconds >= 6000 && userWatchDuration[_msgSender()] == 0
        ) {
            timeSpentInSeconds = 6000;
            isUserDurationLimitReached[_msgSender()] = true;
            userCurrentHalving[_msgSender()] = counter;
        } else if (
            timeSpentInSeconds >= 6000 && userWatchDuration[_msgSender()] != 0
        ) {
            timeSpentInSeconds = 6000 - userWatchDuration[_msgSender()];
            isUserDurationLimitReached[_msgSender()] = true;
            userCurrentHalving[_msgSender()] = counter;
            userWatchDuration[_msgSender()] = 0;
        } else if (
            timeSpentInSeconds < 6000 && userWatchDuration[_msgSender()] == 0
        ) {
            userWatchDuration[_msgSender()] = timeSpentInSeconds;
        } else {
            if (
                (userWatchDuration[_msgSender()]) + timeSpentInSeconds >= 6000
            ) {
                timeSpentInSeconds = 6000 - userWatchDuration[_msgSender()];
                isUserDurationLimitReached[_msgSender()] = true;
                userCurrentHalving[_msgSender()] = counter;
                userWatchDuration[_msgSender()] = 0;
            } else {
                userWatchDuration[_msgSender()] += timeSpentInSeconds;
            }
        }

        // if statement to set the watch time for creators based on user watch time
        if (totalTime != timeSpentInSeconds) {
            uint differenceInTime = totalTime - timeSpentInSeconds;
            for (uint i = (arrOfWatchTime.length - 1); i >= 0; i--) {
                if (differenceInTime == 0) break;
                if (arrOfWatchTime[i] < differenceInTime) {
                    differenceInTime -= arrOfWatchTime[i];
                    arrOfWatchTime[i] = 0;
                } else {
                    arrOfWatchTime[i] -= differenceInTime;
                    differenceInTime = 0;
                }
            }
        }

        uint userAmount;
        uint[] memory arrOfCreatorAmount = new uint[](arrOfWatchTime.length);
        uint creatorRewardArrayCounter = 0;
        if (totalWatchSeconds + timeSpentInSeconds >= 18000000) {
            if (totalWatchSeconds + timeSpentInSeconds == 18000000) {
                userAmount = timeSpentInSeconds * userReward;
                for (
                    uint i = creatorRewardArrayCounter;
                    i < arrOfWatchTime.length;
                    i++
                ) {
                    arrOfCreatorAmount[i] = arrOfWatchTime[i] * creatorReward;
                }
                halving();
            } else {
                uint timeDifference = (totalWatchSeconds + timeSpentInSeconds) -
                    18000000;
                userAmount = (timeSpentInSeconds - timeDifference) * userReward;
                for (uint i = 0; i < arrOfWatchTime.length; i++) {
                    if (arrOfWatchTime[i] + totalWatchSeconds < 18000000) {
                        arrOfCreatorAmount[i] =
                            arrOfWatchTime[i] *
                            creatorReward;
                    } else if (
                        arrOfWatchTime[i] + totalWatchSeconds == 18000000
                    ) {
                        arrOfCreatorAmount[i] =
                            arrOfWatchTime[i] *
                            creatorReward;
                        creatorRewardArrayCounter = i;
                        halving();
                    } else {
                        uint timeDiff = (totalWatchSeconds +
                            arrOfWatchTime[i]) - 18000000;
                        arrOfCreatorAmount[i] =
                            (arrOfWatchTime[i] - timeDiff) *
                            creatorReward;
                        creatorRewardArrayCounter = i;
                        halving();
                        arrOfCreatorAmount[i] += timeDiff * creatorReward;
                    }
                }
                totalWatchSeconds += timeDifference;
                userAmount += timeDifference * userReward;
            }
        } else {
            userAmount = timeSpentInSeconds * userReward;
            totalWatchSeconds += timeSpentInSeconds;
            for (
                uint i = creatorRewardArrayCounter;
                i < arrOfWatchTime.length;
                i++
            ) {
                arrOfCreatorAmount[i] = arrOfWatchTime[i] * creatorReward;
            }
        }
        // Mint tokens to the user to distrubute rewards
        require(
            userRewardMintedSupply + userAmount <=
                1798242188 * (10 ** decimals()),
            "User Reward Tokens fully minted in site"
        );
        _mint(_msgSender(), userAmount);
        userRewardMintedSupply += userAmount;

        // Mint tokens to the creator to distrubute rewards
        for (uint256 i = 0; i < arrOfCreatorAmount.length; i++) {
            require(
                creatorRewardMintedSupply + arrOfCreatorAmount[i] <=
                    1798242188 * (10 ** decimals()),
                "Creator Reward Tokens fully minted in site"
            );
            _mint(creatorOfTheVideo[arrOfVideos[i]], arrOfCreatorAmount[i]);
            creatorRewardMintedSupply += arrOfCreatorAmount[i];
        }
    }
}
