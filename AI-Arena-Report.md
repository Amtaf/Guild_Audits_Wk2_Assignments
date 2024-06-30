## AI ARENA AUDIT REPORT


### [H-1] Incorrect/Inadequate Data Type usage in `FighterFarm::reRoll` Limiting Functionality

**Description:** 

The `FighterFarm::reRoll` function accepts a uint8 type for the tokenId parameter. This data type restricts the tokenId to values between 0 and 255. 


**Impact:** 

Limiting tokenId to uint8 severely restricts the range of valid token IDs to 256 possible values. In a scenario where the contract manages a larger set of NFTs, any token with an ID greater than 255 cannot be re-rolled. This limitation reduces the functionality and flexibility of the contract, potentially rendering it unsuitable for larger NFT collections

**Proof of Concept:**

If the contract uses token IDs larger than 255, these tokens cannot be re-rolled using this function. 

```javascript
function reRoll(uint8 tokenId, uint8 fighterType) public {
    require(msg.sender == ownerOf(tokenId));
    require(numRerolls[tokenId] < maxRerollsAllowed[fighterType]);
    .
    .
}
```
**Recommended Mitigation:** 

Change the data type of the tokenId parameter from uint8 to uint256 to accommodate a wider range of token IDs.

```diff
-  function reRoll(uint8 tokenId, uint8 fighterType) public {
    .
    .
    }

+  function reRoll(uint256 tokenId, uint8 fighterType) public {
    .
    .
    }
```




### [L-1] Inefficient Struct Packing in GameItemAttributes leading to Increased Gas Costs

**Description:** 

The GameItemAttributes struct defined in the contract is not optimally packed. This inefficient packing results in higher gas costs due to increased storage operations. The struct is defined as follows:

```
struct GameItemAttributes {
    string name;
    bool finiteSupply;
    bool transferable;
    uint256 itemsRemaining;
    uint256 itemPrice;
    uint256 dailyAllowance;
}
```
**Impact:** 

Inefficiently packed structs can lead to higher gas costs for users interacting with your contract, potentially making your contract more susceptible to DoS attacks.


**Recommended Mitigation:** 

By placing the uint256 values first and the bool values last, the struct is packed more efficiently, reducing the number of storage slots used and thereby lowering gas costs.

### [L-2] Non-Indexed Event Parameters in `FighterCreated` Event (Potential Efficiency Issue)
**Description:** 

The `FighterOps::FighterCreated` event is defined without indexing any of its parameters. Indexing allows efficient filtering and retrieval of events based on specific parameters. 

**Impact:** 

Without indexing, querying or filtering events based on specific parameters (id, weight, element, generation) becomes inefficient. Indexed parameters enable more efficient event logs handling, especially in scenarios where contracts emit many events or when users need to query historical data based on specific attributes.

**Proof of Concept:**

None of the event parameters (id, weight, element, generation) are marked as indexed. The event is defined as follows:

```javascript
    event FighterCreated(
    uint256 id,
    uint256 weight,
    uint256 element,
    uint8 generation
);

```

**Recommended Mitigation:** 

To improve efficiency and usability, mark relevant parameters(that might be frequently used for filtering /querying) in the FighterCreated event as indexed. 

```javascript
event FighterCreated(
    uint256 indexed id,
    uint256 weight,
    uint256 element,
    uint8 indexed generation
);
```
