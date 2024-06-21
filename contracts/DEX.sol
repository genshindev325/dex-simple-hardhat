// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC20.sol"; // Interface for ERC20 tokens

contract DEX {
    address public admin; // Admin address
    mapping(address => mapping(address => uint256)) public balances; // User balances
    mapping(address => bool) public tokens; // Listed tokens

    event Deposit(address indexed token, address indexed user, uint256 amount);
    event Withdraw(address indexed token, address indexed user, uint256 amount);
    event Trade(address indexed tokenGive, uint256 amountGive, address indexed tokenGet, uint256 amountGet);

    constructor() {
        admin = msg.sender; // Deployer is admin
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin allowed");
        _;
    }

    function addToken(address _token) external onlyAdmin {
        tokens[_token] = true; // Add token to list
    }

    function deposit(address _token, uint256 _amount) external {
        require(tokens[_token], "Token not listed");
        IERC20(_token).transferFrom(msg.sender, address(this), _amount); // Transfer tokens to contract
        balances[msg.sender][_token] += _amount; // Increase user balance
        emit Deposit(_token, msg.sender, _amount);
    }

    function withdraw(address _token, uint256 _amount) external {
        require(balances[msg.sender][_token] >= _amount, "Insufficient balance");
        balances[msg.sender][_token] -= _amount; // Decrease user balance
        IERC20(_token).transfer(msg.sender, _amount); // Transfer tokens to user
        emit Withdraw(_token, msg.sender, _amount);
    }

    function trade(address _tokenGive, uint256 _amountGive, address _tokenGet, uint256 _amountGet) external {
        require(tokens[_tokenGive] && tokens[_tokenGet], "Tokens not listed");
        require(balances[msg.sender][_tokenGive] >= _amountGive, "Insufficient balance");

        uint256 amountNeeded = (_amountGet * _amountGive) / _amountGet; // Calculate required amount

        balances[msg.sender][_tokenGive] -= _amountGive; // Decrease user balance
        balances[msg.sender][_tokenGet] += amountNeeded; // Increase user balance
        emit Trade(_tokenGive, _amountGive, _tokenGet, amountNeeded);
    }
}
