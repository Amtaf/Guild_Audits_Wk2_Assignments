// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SimpleStaking {
    // State variables
    IERC20 public stakingToken;
    mapping(address => uint256) public stakedAmounts;
    mapping(address => uint256) public rewardBalances;
    uint256 public rewardRate = 100; // Reward rate per block per staked token
    address public owner;

    
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 amount);

    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }


    constructor(IERC20 _stakingToken) {
        stakingToken = _stakingToken;
        owner = msg.sender;
    }

    // Stake function
    function stake(uint256 _amount) external payable {
        require(_amount > 0, "Cannot stake 0");

        // Update reward balance before modifying staked amount
        rewardBalances[msg.sender] += calculateReward(msg.sender);
        stakedAmounts[msg.sender] += _amount;
        stakingToken.transferFrom(msg.sender, address(this), _amount);

        emit Staked(msg.sender, msg.value);
    }

    // Withdraw function
    function withdraw(uint256 _amount) external {
        require(_amount > 0, "Cannot withdraw 0");
        require(stakedAmounts[msg.sender] >= _amount, "Insufficient staked amount");

        // Update reward balance before modifying staked amount
        rewardBalances[msg.sender] += calculateReward(msg.sender);
        stakedAmounts[msg.sender] -= _amount;

        stakingToken.transfer(msg.sender, _amount);
        emit Withdrawn(msg.sender, _amount);
    }

    // Claim reward function
    function claimReward() external {
        uint256 reward = rewardBalances[msg.sender];
        require(reward > 0, "No reward to claim");

        rewardBalances[msg.sender] = 0;
        stakingToken.transfer(msg.sender, reward);
        emit RewardClaimed(msg.sender, reward);
    }

    // Calculate reward function
    function calculateReward(address _user) internal view returns (uint256) {
        return stakedAmounts[_user] * rewardRate * block.number;
    }

    // Owner functions
    function setRewardRate(uint256 _rate) external onlyOwner {
        rewardRate = _rate;
    }

    function withdrawContractBalance(uint256 _amount) external onlyOwner {
        require(_amount <= address(this).balance, "Insufficient contract balance");
        stakingToken.transfer(owner,_amount);
    }
}
