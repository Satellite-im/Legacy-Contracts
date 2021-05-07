// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.8.0;

/**
 * @title DwellerID
 * @dev Represents identification of a Vault Dweller
 */
contract DwellerID {
    // The parent registry that created this identification contract
    address public registry;
    // The dweller represents the owner of this identification contract
    address public dweller;
    // This is the display name of a dweller
    string public name;
    // Optional photo identification of the dweller
    string public photoHash;
    // String public key
    bytes public pubkey;
    // User status message
    string public status = "Sitting in orbit...";

    address[] private servers;


    // Events
    event DwellerSet(address indexed dweller);
    event PhotoSet (string indexed photoHash);

    // modifier to check if caller is owner
    modifier isOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        require(msg.sender == dweller, "Not the dweller we're expecting.");
        _;
    }
    modifier isRegistry() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        require(msg.sender == registry, "Only callable by registry.");
        _;
    }
    modifier isRegistryOrOwner() {
        require(msg.sender == registry || msg.sender == dweller, "Only callable by registry or owner.");
        _;
    }

    /**
     * @dev Set contract deployer as dweller (owner)
     * @param _name What should we call you, dweller?
     */
    constructor(string memory _name, address _dweller, bytes memory _pubkey) {
        registry = msg.sender;
        dweller = _dweller;
        name = _name;
        pubkey = _pubkey;
        emit DwellerSet(dweller);
    }

    /**
     * Getters
     */

    /**
     * @dev Return owner address 
     * @return address_ owner address of dweller 
     * @return name_ name of the dweller
     * @return photoHash_ string representation of the IPFS hash
     * @return pubkey_ user public key
     * @return status_ user status message
     */
    function getDweller() 
        external 
        view 
        returns (
            address address_, 
            string memory name_, 
            string memory photoHash_, 
            bytes memory pubkey_,
            string memory status_
        )
    {
        return (dweller, name, photoHash, pubkey, status);
    }

    function getServers() 
        public
        view
        isRegistryOrOwner
        returns (address[] memory)
    {
        return servers;
    }

    /**
     * @dev Add a server from list of server contracts
     * @param server Address pointing to server contract
     */
    function joinServer(address server) 
        public
        isRegistry
    {
        servers.push(server);
    }

    /**
     * @dev Remove server from list of server contracts
     * @param server Address pointing to server contract
     */
    function leaveServer(address server) 
        public
        isRegistry
    {
        if (servers.length == 0) return;
        uint indx;
        for (uint i = 0; i < servers.length-1; i++){
            if (servers[i] == server) {
                indx = i;
            }
        }
        delete servers[indx];
        
    }

    /**
     * @dev Change dweller's display name
     * @param _name What should we call you, dweller?
     */
    function setDwellerName(string memory _name) 
        public
        isOwner
    {
        name = _name;
    }

    /**
     * @dev Change dweller's display photo. Consider using PNG or JPEG photos for usability.
     * @param _photoHash string representation of the IPFS hash
     */
    function setPhoto(string memory _photoHash) 
        public 
        isOwner 
    {
        photoHash = _photoHash;
        emit PhotoSet(photoHash);
    }

    /**
     * @dev Update the users status
     * @param _status string status to set.
     */
    function setStatus(string memory _status) 
        public
        isOwner
    {
        status = _status;
    }
}