pragma solidity ^0.7.0;

import "./DappToken.sol";
import "./DaiToken.sol";

contract TokenFarm {
    string public name = "Dapp Token Farm";
    address public owner; 
    // this is a smart contract
    DappToken public dappToken;
    DaiToken public daiToken;

    address[] public stakers;
    mapping(address => uint) public stakingBalance;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaking;


    constructor(DappToken _dappToken, DaiToken _daiToken) {
        dappToken = _dappToken;
        daiToken = _daiToken;
        owner = msg.sender;
    }

    // 1. Stakes Tokens (Deposit)
    function stakeTokens(uint _amount) public {
        daiToken.transferFrom(msg.sender, address(this), _amount);
        
        // update staking balance
        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;

        if (!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }

        hasStaked[msg.sender] = true;
        isStaking[msg.sender] = true;
    }

    // 2. Unstake Tokens (Withdraw)
    function unstakeTokens() public {
        uint balance = stakingBalance[msg.sender];

        require(balance > 0, "staking balance cannot be 0");

        daiToken.transfer(msg.sender, balance);
        stakingBalance[msg.sender] = 0;
        isStaking[msg.sender] = false;

        for (uint i = 0; i < stakers.length; i++) {
            if (stakers[i] == msg.sender) {
                delete stakers[i];
            }
        }
    }


    // 3. Issuing Tokens
    function issueTokens() public {
        require(msg.sender == owner, "caller must be owner");
        for (uint i = 0; i < stakers.length; i++) {
            address recipient = stakers[i];
            uint balance = stakingBalance[recipient];
            if (balance > 0) {
                dappToken.transfer(recipient, balance); 
            }
        }
    }

}
