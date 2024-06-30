// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Dex} from "../src/Dex.sol";
import {HackDex} from "../src/HackDex.sol";


contract MockERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract DexTest is Test {
    Dex public dex;
    // IERC20 public token1;
    // IERC20 public token2;
    MockERC20 public token1;
    MockERC20 public token2;

    HackDex public hackDex;


    function setUp() public {
        dex = new Dex(address(this));
        // token1 = IERC20(Token1);
        // token2 = IERC20(Token2);
        token1 = new MockERC20("Token1", "TKN1");
        token2 = new MockERC20("Token2", "TKN2");

      
        token1.mint(address(this), 110);
        token2.mint(address(this), 110);
        token1.mint(address(dex), 100);
        token2.mint(address(dex), 100);

        dex.setTokens(address(token1), address(token2));

        hackDex = new HackDex(address(dex), address(token1), address(token2));


        // Transfer initial tokens to the HackDex contract
        token1.transfer(address(hackDex), 10);
        token2.transfer(address(hackDex), 10);
    }
  function testAttack() public {
        token1.approve(address(dex), 110);
        token2.approve(address(dex), 110);

        token1.approve(address(hackDex), 110);
        token2.approve(address(hackDex), 110);

        dex.addLiquidity(address(token1), 100);
        dex.addLiquidity(address(token2), 100);

        hackDex.attakc();


        // Assert the DEX is drained of one of the tokens
        assertEq(token1.balanceOf(address(dex)), 0);
        //assertEq(token2.balanceOf(address(dex)), 0);
    }
}