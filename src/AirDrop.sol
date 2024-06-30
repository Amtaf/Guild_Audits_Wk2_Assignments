// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract VulnerableAirdrop is Ownable{
    //token to be airdropped
    IERC20 public token;
    using ECDSA for bytes32;

    //mapping(address=>uint256) public nonces; 

    constructor(address _tokenAddress, address initialOwner) Ownable(initialOwner){
        token = IERC20(_tokenAddress);
        
    }
    function toEthSignedMessageHash(bytes32 hash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
    function claimAirdrop(uint256 amount,uint256 nonce, bytes memory signature) external{
        //hashes the sender address, amount, and nonce
        bytes32 messageHash = keccak256(abi.encodePacked(msg.sender,amount,nonce));
        bytes32 ethSignedMessageHash = toEthSignedMessageHash(messageHash);
        //recovers the signer's address from the provided signature
        address signer = ethSignedMessageHash.recover(signature);
        require(signer == owner(),"Invalid Signature Not Owner!!");
        
        token.transfer(msg.sender, amount);
    }

}