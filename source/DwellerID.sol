pragma solidity >=0.4.22 <0.7.0;

/**
 * @title DwellerID
 * @dev Represents identification of a Vault Dweller
 */
contract DwellerID {
    // The parent registry that created this identification contract
    address public registry;
    // The dweller represents the owner of this identification contract
    address private dweller;
    // This is the display name of a dweller
    bytes32 private name;
    // Optional photo identification of the dweller
    // Stored as a split Multihash referencing IPFS hash of dwellers photo
    bytes32 private photoHashBeg;
    bytes32 private photoHashEnd;

    // Events
    event DwellerSet(address indexed dweller);
    event PhotoSet (
        bytes32 indexed photoHashBeg,
        bytes32 indexed photoHashEnd
    );

    // modifier to check if caller is owner
    modifier isOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        require(msg.sender == dweller, "Not the dweller we're expecting.");
        _;
    }

    /**
     * @dev Set contract deployer as dweller (owner)
     * @param _name What should we call you, dweller?
     */
    constructor(bytes32 _name, address _dweller) public {
        registry = msg.sender;
        dweller = _dweller;
        name = _name;
        emit DwellerSet(dweller);
    }

    /**
     * Getters
     */

    /**
     * @dev Return owner address 
     * @return address_ owner address of dweller 
     * @return name_ name of the dweller
     * @return photoIPFSHash1_ part 1 of the dwellers photo IPFS hash
     * @return photoIPFSHash2_ part 2 of the dwellers photo IPFS hash
     */
    function getDweller() 
        external 
        view 
        returns (
            address address_, 
            bytes32 name_,
            bytes32 photoIPFSHash1_,
            bytes32 photoIPFSHash2_
        )
    {
        return (dweller, name, photoHashBeg, photoHashEnd);
    }

    /**
     * @dev Return dweller's address (owner address)
     * @return dweller address
     */
    function getDwellerAddress() 
        external 
        view 
        returns (address) 
    {
        return dweller;
    }

    /**
     * @dev Return dweller's name (display name)
     * @return dweller name
     */
    function getDwellerName() 
        external 
        view 
        returns (bytes32) 
    {
        return name;
    }

    /**
     * @dev Get the dweller's photo IPFS hash
     * @return dweller photo IPFS hash
     */
    function getPhoto() 
        public 
        view 
        returns (bytes memory) 
    {
        bytes memory joined = new bytes(64);
        // Join the two hash parts of photos IPFS hash
        assembly {
            mstore(add(joined, 32), sload(photoHashBeg_slot))
            mstore(add(joined, 64), sload(photoHashEnd_slot))
        }
        return joined; 
    }

    /**
     * Setters
     */

    /**
     * @dev Change dweller's display name
     * @param _name What should we call you, dweller?
     */
    function setDwellerName(bytes32 _name) 
        public 
        isOwner 
    {
        name = _name;
    }

    /**
     * @dev Change dweller's display photo. Consider using PNG or JPEG photos for usability.
     * @param hash split multihash referencing the IPFS hash for the photo
     */
    function setPhoto(bytes32[2] memory hash) 
        public 
        isOwner 
    {
        photoHashBeg = hash[0];
        photoHashEnd = hash[1];
        emit PhotoSet(photoHashBeg, photoHashEnd);
    }
}