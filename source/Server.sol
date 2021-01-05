// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.8.0;

import "./Vault74Registry.sol";

/**
 * @title Server
 * @dev Identifies a Vault74 server used to communicate with many dwellers
 */
contract Server {
    // The parent registry that created this server contract
    address public registry;
    // The dweller represents the owner of this server
    address private dweller;
    // This is the display name of the server
    bytes32 public name;
    // Optional photo identification of the server
    // Stored as a split Multihash referencing IPFS hash of servers photo
    bytes32 private photoHash1;
    bytes32 private photoHash2;
    // Optional additional info access hash
    bytes32 private dbHash1;
    bytes32 private dbHash2;
    // Server memebers whom have joined
    address[] public members;
    // Check a eth address to see if the member has access
    // if they do, they will have a truthy bool set
    mapping(address => bool) public memberStatus;
    // Administrators
    mapping(address => bool) public administrators;
    // Channels
    bytes32[] public channels;
    // Name -> TypeId
    mapping(bytes32 => uint8) public channelTypes;
    // Used to store channels in specific groups
    bytes32[] public groups;
    mapping(bytes32 => bytes32[]) public groupings;

    /**
     * Events
     */
    // Internal
    event DwellerSet(address indexed dweller);
    // Information
    event NameChanged(bytes32 indexed name);
    event PhotoSet (
        bytes32 indexed photoHash1,
        bytes32 indexed photoHash2
    );
    // Members & Roles
    event MemberInvited(address indexed member);
    event MemberJoined(address indexed member);
    event MemberLeft(address indexed member);
    event AdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);
    event MemberRevoked(address indexed member);
    // Groups
    event GroupCreated(bytes32 indexed groupName);
    event GroupDeleted(bytes32 indexed groupName);
    event ChannelGrouped(bytes32 indexed groupName, bytes32 indexed channelName);
    event ChannelRemovedFromGroup(bytes32 indexed groupName);
    // Channels
    event ChannelCreated(
        bytes32 indexed name,
        uint8 indexed typeId
    );
    event ChannelDeleted( bytes32 indexed name);
    
    /**
     * @dev Set contract deployer as dweller (owner)
     * @param _name What should we call your server?
     */
    constructor(bytes32 _name, address _dweller) {
        registry = msg.sender;
        dweller = _dweller;
        name = _name;
        // Set the owner as an administrator
        administrators[dweller] = true;
        members.push(_dweller);
        // Emit events
        emit DwellerSet(dweller);
        emit AdminAdded(dweller);
    }

    /**
     * Modifiers
     */

    // modifier to check if caller is owner
    modifier isOwner() {
        require(msg.sender == dweller, "Not the dweller we're expecting.");
        _;
    }
    // modifier to check if caller is owner
    modifier isRegistry() {
        require(msg.sender == registry, "Only the registry may execute this.");
        _;
    }
    // modifier to check if caller is admin
    modifier isAdmin() {
        require(administrators[msg.sender], "Not authorized to do that.");
        _;
    }
    
    /**
     * Getters
     */
    
    function getMembers() 
        public
        view
        returns (address[] memory)
    {
        return members;
    }
    
    function getChannels() 
        public
        view
        returns (bytes32[] memory)
    {
        return channels;
    }
    
    function getGroups() 
        public
        view
        returns (bytes32[] memory)
    {
        return groups;
    }

    /**
     * @dev Get the servers's photo IPFS hash
     * @return server photo IPFS hash
     */
    function getPhoto() 
        public 
        view 
        returns (bytes memory) 
    {
        bytes memory joined = new bytes(64);
        // Join the two hash parts of photos IPFS hash
        assembly {
            mstore(add(joined, 32), sload(photoHash1.slot))
            mstore(add(joined, 64), sload(photoHash2.slot))
        }
        return joined; 
    }

    /**
     * @dev Get the servers's photo IPFS hash
     * @return server photo IPFS hash
     */
    function getDBHash() 
        public 
        view 
        returns (bytes memory) 
    {
        bytes memory joined = new bytes(64);
        // Join the two hash parts
        assembly {
            mstore(add(joined, 32), sload(dbHash1.slot))
            mstore(add(joined, 64), sload(dbHash2.slot))
        }
        return joined; 
    }
    
    function getMemberAtIndex(uint indx)
        public
        view
        returns (address) 
    {
        return members[indx];
    }

    /**
     * Setters
     */

    // Channels
    function addChannel(bytes32 _name, uint8 typeId) 
        public
        isAdmin
    {
        channels.push(_name);
        channelTypes[_name] = typeId;
        emit ChannelCreated(_name, typeId);
    }

    function delChannel(uint indx) 
        public
        isAdmin
    {
        bytes32 channelName = channels[indx];
        delete channels[indx];
        delete channelTypes[channelName];
        emit ChannelDeleted(channelName);
    }
    
    // Groups
    function createGroup(bytes32 groupName) 
        public
        isAdmin
    {
        groups.push(groupName);
        emit GroupCreated(groupName);
    }

    function delGroup(uint indx) 
        public
        isAdmin
    {
        bytes32 groupName = groups[indx];
        delete groupings[groupName];
        delete groups[indx];
        emit GroupDeleted(groupName);
    }
    
    function addChannelToGroup(bytes32 groupName, bytes32 channelName)
        public
        isAdmin
    {
        groupings[groupName].push(channelName);
        emit ChannelGrouped(groupName, channelName);
    }
    
    function removeChannelFromGroup(bytes32 groupName, uint channelIndex)
        public
        isAdmin
    {
        delete groupings[groupName][channelIndex];
        emit ChannelRemovedFromGroup(groupName);
    }

    // Roles
    function addAdmin(address admin) 
        public
        isOwner
    {
        administrators[admin] = true;
        emit AdminAdded(admin);
    }

    function removeAdmin(address admin) 
        public
        isOwner
    {
        require(admin != dweller, "You can't remove the owner as admin");
        administrators[admin] = false;
        emit AdminRemoved(admin);
    }

    // Members
    function join(address member) 
        public
        isRegistry
    {
        require(memberStatus[member] == true, "Member not authorized to join the server.");
        members.push(member);
        emit MemberJoined(member);
    }
    
    function leave(uint indx)
        public
        isRegistry
    {
        delete members[indx];
        emit MemberLeft(members[indx]);
    }
    
    function inviteMember(address member)
        public
        isAdmin
    {
        memberStatus[member] = true;
        emit MemberInvited(member);
    }

    function revokeMember(address member)
        public
        isAdmin
    {
        memberStatus[member] = false;
        emit MemberRevoked(member);
    }

    /**
     * @dev Change servers's display name
     * @param _name What should we call your server
     */
    function setName(bytes32 _name)
        public
        isAdmin
    {
        emit NameChanged(_name);
        name = _name;
    }

    /**
     * @dev Change servers's display photo. Consider using PNG or JPEG photos for usability.
     * @param hash split multihash referencing the IPFS hash for the photo
     */
    function setPhoto(bytes32[2] memory hash) 
        public 
        isAdmin 
    {
        photoHash1 = hash[0];
        photoHash2 = hash[1];
        emit PhotoSet(photoHash1, photoHash2);
    }
    
    /**
     * @dev Change dweller's display photo. Consider using PNG or JPEG photos for usability.
     * @param hash split multihash
     */
    function setDBHash(bytes32[2] memory hash) 
        public 
        isAdmin 
    {
        dbHash1 = hash[0];
        dbHash2 = hash[1];
        emit PhotoSet(dbHash1, dbHash2);
    }
}