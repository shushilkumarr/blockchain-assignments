// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20Capped} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {Ownable2Step,Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";

contract InfinityStones is ERC20, ERC20Burnable, ERC20Capped, Pausable, Ownable2Step {
    uint256 public constant MAX_SUPPLY = 5 * 10**18;
    mapping(address => mapping(address => bool)) private _friends;

    constructor() ERC20("InfinityStones", "INF_STONES") ERC20Capped(MAX_SUPPLY) Ownable(msg.sender) {
        mint(msg.sender, MAX_SUPPLY);
    }

    event FriendAdded(address indexed holder, address indexed friend);
    event FriendRemoved(address indexed holder, address indexed friend);

    function mint(address to, uint256 amount) public virtual onlyOwner whenNotPaused {
        _mint(to, amount);
    }

    function pause() public virtual onlyOwner {
        _pause();
    }

    function unpause() public virtual onlyOwner {
        _unpause();
    }

    function _update(
        address from,
        address to,
        uint256 value
    ) internal override(ERC20, ERC20Capped) whenNotPaused {
        // If normal transfer (not mint, not burn)
        if (from != address(0) && to != address(0)) {
            require(_friends[from][to], "Receiver is not your friend");
        }

        super._update(from, to, value);
    }

    function addFriend(address friend) external {
        require(friend != address(0), "Invalid friend");
        _friends[msg.sender][friend] = true;
        emit FriendAdded(msg.sender, friend);
    }

    function removeFriend(address friend) external {
        _friends[msg.sender][friend] = false;
        if (allowance(msg.sender, friend) > 0) {
            _approve(msg.sender, friend, 0);
        }
        emit FriendRemoved(msg.sender, friend);
    }

    function isFriend(address holder, address friend) public virtual returns (bool)
    {
        return _friends[holder][friend];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        require(_friends[msg.sender][spender], "Spender is not your friend");
        _approve(msg.sender, spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(_friends[msg.sender][spender], "Spender is not your friend");
        _approve(msg.sender, spender, allowance(msg.sender, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(_friends[msg.sender][spender], "Spender is not your friend");
        uint256 current = allowance(msg.sender, spender);
        require(current >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(msg.sender, spender, current - subtractedValue);
        return true;
    }
}
