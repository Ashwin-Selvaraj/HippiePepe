/**
 *Submitted for verification at basescan.org on 2024-03-13
 */

/**
 *Submitted for verification at basescan.org on 2024-03-11
 */

// SPDX-License-Identifier: MIT

// Bratt is the son of Brett who desires to follow his dad's footsteps in conquering the charts of the Base Network.
// Bratt, just like his dad, is a character oozing with so much personality.
// He is naughty, mischievous and sometimes crazy and wild, but his heart is always in the right place.

// Join Bratt as we traverse the journey towards a milly, starting today!

// Website: https://basedbratt.xyz
// TG: https://t.me/sonofbrett
// Twitter: https://x.com/brattsonofbrett

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
    uint256 public mintedSupply;
    uint256 public blockReward;
    uint256 public totalWatchMinutes;
    uint256 public counter;
    uint256 public watchTimeCooldown; // Cooldown period between watch time resets (in seconds)
    mapping(address => uint256) public lastWatchedTime;
    mapping(address => uint256) public watchStartTime;
    mapping(address => uint256) public userWatchTime;

    //Time duration required for minting eligibility (in seconds)
    // uint256 public constant requiredTime = 300; // 5 mins for example, adjust as needed
    // Mapping to track the last time each user watched TV

    constructor()
        ERC20("Hippie Pepe", "HPMT")
        ERC20Capped(4200000000 * (10 ** decimals()))
    {
        mint(msg.sender, 840000000); //amount = 20% (for team - 5% and development - 15%)
        blockReward = 1000 * (10 ** decimals());
        watchTimeCooldown = 86400; // 24 hours cooldown
    }

    // function to distriibute tokens
    function distributeTokens(
        address distributionWallet,
        uint supply
    ) external onlyOwner {
        require(supply <= balanceOf(msg.sender), "Insufficient balance");
        _transfer(
            msg.sender,
            distributionWallet,
            (supply * (10 ** decimals()))
        );
    }

    function mint(
        address account,
        uint256 amount
    ) public onlyOwner returns (bool) {
        require(
            ERC20.totalSupply() + (amount * 10 ** decimals()) <= cap(),
            "ERC20Capped: cap exceeded"
        );
        _mint(account, (amount * 10 ** decimals()));
        return true;
    }

    function halving() private {
        require(
            totalWatchMinutes >= 25200000,
            "Halving occurs only after 420000 minutes of watch time"
        );
        counter++;
        totalWatchMinutes = 0;
        blockReward /= 2;
    }

    function coolingPeiodCheck() public view returns (bool) {
        return (lastWatchedTime[msg.sender] + watchTimeCooldown <
            block.timestamp);
    }

    function mintWithWatchTime(uint timeSpentInMinutes) external {
        require(coolingPeiodCheck(), "Watch time cooldown has not expired yet");
        // if - to check 24hrs from watch start time is over
        if (
            (watchStartTime[msg.sender] == 0) ||
            ((watchStartTime[msg.sender] + 86400) > block.timestamp)
        ) {
            if (
                (timeSpentInMinutes > 30 || timeSpentInMinutes == 30) &&
                userWatchTime[msg.sender] == 0
            ) {
                timeSpentInMinutes = 30;
                watchStartTime[msg.sender] =
                    block.timestamp -
                    (timeSpentInMinutes * 60);
                lastWatchedTime[msg.sender] = block.timestamp;
                userWatchTime[msg.sender] = 0;
            } else if (
                (timeSpentInMinutes > 30 || timeSpentInMinutes == 30) &&
                userWatchTime[msg.sender] != 0
            ) {
                timeSpentInMinutes = 30 - (userWatchTime[msg.sender] / 60);
                lastWatchedTime[msg.sender] = block.timestamp;
                userWatchTime[msg.sender] = 0;
            } else if (
                timeSpentInMinutes < 30 && userWatchTime[msg.sender] == 0
            ) {
                userWatchTime[msg.sender] = timeSpentInMinutes * 60;
                watchStartTime[msg.sender] =
                    block.timestamp -
                    (timeSpentInMinutes * 60);
            } else {
                if (
                    (userWatchTime[msg.sender] / 60) + timeSpentInMinutes >= 30
                ) {
                    timeSpentInMinutes = 30 - (userWatchTime[msg.sender] / 60);
                    lastWatchedTime[msg.sender] = block.timestamp;
                    userWatchTime[msg.sender] = 0;
                } else {
                    userWatchTime[msg.sender] += (timeSpentInMinutes * 60);
                    if ((userWatchTime[msg.sender] / 60) >= 30) {
                        lastWatchedTime[msg.sender] = block.timestamp;
                        userWatchTime[msg.sender] = 0;
                    }
                }
            }
        } else {
            if (timeSpentInMinutes > 30 || timeSpentInMinutes == 30) {
                timeSpentInMinutes == 30;
                watchStartTime[msg.sender] =
                    block.timestamp -
                    (timeSpentInMinutes * 60);
                lastWatchedTime[msg.sender] = block.timestamp;
                userWatchTime[msg.sender] = 0;
            } else {
                userWatchTime[msg.sender] = (timeSpentInMinutes * 60);
                watchStartTime[msg.sender] =
                    block.timestamp -
                    (timeSpentInMinutes * 60);
            }
        }
        uint amount;
        if (totalWatchMinutes + (timeSpentInMinutes * 60) >= 25200000) {
            if (totalWatchMinutes + (timeSpentInMinutes * 60) == 25200000) {
                amount = timeSpentInMinutes * blockReward;
                halving();
            } else if (
                totalWatchMinutes + (timeSpentInMinutes * 60) > 25200000
            ) {
                uint timeDifference = totalWatchMinutes +
                    (timeSpentInMinutes * 60) -
                    25200000;
                amount =
                    (timeSpentInMinutes - (timeDifference / 60)) *
                    blockReward;
                halving();
                totalWatchMinutes += timeDifference;
                amount += (timeDifference / 60) * blockReward;
            }
        } else {
            amount = timeSpentInMinutes * blockReward;
            totalWatchMinutes += (timeSpentInMinutes * 60);
        }
        // Mint tokens to caller
        require(
            mintedSupply + amount <= 840000000 * (10 ** decimals()),
            "Tokens fully minted in site"
        );
        _mint(msg.sender, amount); // Adjust minting amount as needed
        mintedSupply += amount;
    }
}
