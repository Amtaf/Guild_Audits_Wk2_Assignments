// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SimpleStaking} from "../src/Staking.sol";


//contract of token for test
contract MyToken is ERC20 {
    constructor() ERC20("MyToken", "MTK") {
        _mint(msg.sender, 1000000 * 10**18);
    }
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract TestStaking is Test{
    MyToken token;
    SimpleStaking stakingContract;

    function setUp() public{
        token = new MyToken();
        stakingContract = new SimpleStaking(IERC20(token));
        
    }
    function testFuzz_Stake(uint256 _amount) public{
        _amount = _amount % (10**6 * 10**18);
        vm.assume(_amount > 0);

        // Mint tokens to the test contract and approve staking
        token.mint(address(this), _amount);
        token.approve(address(stakingContract), _amount);

        // Record initial state
        uint256 initialBalance = token.balanceOf(address(this));
        uint256 initialContractBalance = token.balanceOf(address(stakingContract));

        // Call the stake function
        stakingContract.stake(_amount);

        // Check the final state
        uint256 finalBalance = token.balanceOf(address(this));
        uint256 finalContractBalance = token.balanceOf(address(stakingContract));
        uint256 stakedAmount = stakingContract.stakedAmounts(address(this));

        // Assert the changes in state
        assertEq(finalBalance, initialBalance - _amount);
        assertEq(finalContractBalance, initialContractBalance + _amount);
        assertEq(stakedAmount, _amount);
    }

}