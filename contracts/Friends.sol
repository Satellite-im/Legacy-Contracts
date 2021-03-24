// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.8.0;
pragma experimental ABIEncoderV2;

/**
 * @title FriendRequester
 * @dev Maps friend requests along with associated threadIDs
 */
contract Friends {
    
    struct FriendRequest {
        address sender;
        bytes pubkey;
    }

    struct Friend {
        address dweller; // Address of the friend
        bytes32 threadHash1; // Part 1 of the convorsation ThreadID
        bytes32 threadHash2; // Part 2 of the convorsation ThreadID
        bytes pubkey; // Public key used to compute ECDH (Elliptic Curve Diffie Helman)
    }
    
    uint MAX_UINT = uint256(-1);

    event FriendRequestSent(address indexed sentTo);

    event FriendRequestAccepted(address indexed sentFrom);

    event FriendRequestDenied(address indexed sentFrom);
    
    // Emitted when a user removes a friend
    event FriendRemoved(address indexed friendRemoved);

    // Mapping of all friends requests a particular address has
    mapping(address => FriendRequest[]) private requests;
    
    // Tracks the index of each friend request inside the mapping
    mapping(address => mapping(address => uint)) private requestsTracker;
    
    // Mapping of all friends a particular address has
    mapping(address => Friend[]) private friends;
    
    // Tracks the index of each Friend inside the mapping
    mapping(address => mapping(address => uint)) private friendsTracker;
    
    
    /**
     * @dev Create a new Friends contract
     */
    constructor() {}

    /**
     * @dev Converts the given public key to ethereum address
     * @return addr
     */
    function calculateAddress(bytes memory pub) public pure returns (address addr) {
        bytes32 hash = keccak256(pub);
        assembly {
            mstore(0, hash)
            addr := mload(0)
        }    
    }

    /**
     * @dev Returns a friend from the friends mapping
     * @return fr
     */
    function _getFriend(address _from, address _toGet) internal view returns (Friend memory fr) {
        uint index = friendsTracker[_from][_toGet];
        require(index != 0, "Friend does not exist");
        return friends[_from][index - 1];
    }
    
    /**
     * @dev Adds a friend to the friends mapping
     */
    function _addFriend(address _to, Friend memory fr) internal {
        friends[_to].push(fr);
        uint index = friends[_to].length;
        friendsTracker[_to][fr.dweller] = index;
    }
    
    /**
     * @dev Removes a friend from the friends mapping
     */
    function _removeFriend(address _from, address _toRemove) internal {
        require(friends[_from].length > 0, "There are no friends to remove");
        // Index of the element to remove
        uint index = friendsTracker[_from][_toRemove] - 1;
        uint lastIndex = friends[_from].length - 1;
        
        if(index != lastIndex){
            // Last friend inside the array
            Friend memory last = friends[_from][lastIndex];
            // Change the last with the element to remove
            friends[_from][index] = last;
            // Update the Index
            friendsTracker[_from][last.dweller] = index + 1;
        }
        
        // Clear the previous index by setting the maximum integer
        friendsTracker[_from][_toRemove] = MAX_UINT;
        
        // Reduce the size of the array by 1
        friends[_from].pop();
    }
    
    /**
     * @dev Returns a friend request from the requests mapping
     * @return fr
     */
    function _getRequest(address _from, address _toGet) internal view returns (FriendRequest memory fr) {
        uint index = requestsTracker[_from][_toGet];
        require(index != 0, "Request does not exist");
        return requests[_from][index];
    }
    
    /**
     * @dev Adds a friend request to the requests mapping
     */
    function _addRequest(address _to, FriendRequest memory _from) internal {
        requests[_to].push(_from);
        uint index = requests[_to].length;
        requestsTracker[_to][_from.sender] = index;
    }
    
    /**
     * @dev Removes a friend request from the requests mapping
     */
    function _removeRequest(address _from, address _toRemove) internal {
        require(requests[_from].length > 0, "There are no requests to remove");
        // Index of the element to remove
        uint index = requestsTracker[_from][_toRemove] - 1;
        uint lastIndex = requests[_from].length - 1;
        
        if(index != lastIndex){
            // Last friend inside the array
            FriendRequest memory last = requests[_from][lastIndex];
            // Change the last with the element to remove
            requests[_from][index] = last;
            // Update the Index
            requestsTracker[_from][last.sender] = index + 1;
        }
        
        // Clear the previous index by setting the maximum integer
        requestsTracker[_from][_toRemove] = MAX_UINT;
        
        // Reduce the size of the array by 1
        requests[_from].pop();
    }

    /**
     * @dev Add a new friend request
     */
    function makeRequest(address to, bytes memory pubkey) public {
        uint index = requestsTracker[to][msg.sender];
        require(index == 0 || index == MAX_UINT, "Request already sent");

        _addRequest(
            to,
            FriendRequest(msg.sender, pubkey)
        );

        emit FriendRequestSent(to);
    }
    
    /**
     * @dev Accept a friend request
     */
    function acceptRequest(address to, bytes32[2] memory thread, bytes memory pubkey) public {
        uint friendRequestIndex = requestsTracker[msg.sender][to];
        
        // Check if the friend request has already been removed
        require(friendRequestIndex != MAX_UINT, "Friend request has been removed");
        
        // Check if the request exist
        FriendRequest memory friendRequest = requests[msg.sender][friendRequestIndex -1];
        require(friendRequest.sender != address(0), "Request does not exist");
        
        // Current sender
        Friend memory receiverFriend = Friend(
            to,
            thread[0],
            thread[1],
            friendRequest.pubkey
        );
        
        // Original sender of the request
        Friend memory senderFriend = Friend(
            msg.sender,
            thread[0],
            thread[1],
            pubkey
        );
        
        _removeRequest(msg.sender, friendRequest.sender);
        _addFriend(msg.sender, receiverFriend);
        _addFriend(friendRequest.sender, senderFriend);

        emit FriendRequestAccepted(to);
    }

    /**
     * @dev Deny a friend request
     */
    function denyRequest(address to) public {
        uint friendRequestIndex = requestsTracker[msg.sender][to];
        
        // Check if the friend request exist
        require(friendRequestIndex != 0, "Request does not exist");
        
        // Check if the friend request has already been removed
        require(friendRequestIndex != MAX_UINT, "Friend request has been removed");
        
        _removeRequest(msg.sender, to);

        emit FriendRequestDenied(to);
    }

    /**
     * @dev Remove a friend request
     */
    function removeRequest(address to) public {
        uint index = requestsTracker[to][msg.sender];
        require(index != 0, "Request do not exsist");

        _removeRequest(to, msg.sender);
    }

    /**
     * @dev Remove a friend
     */
    function removeFriend(address _toRemove) public {
        uint index = requestsTracker[msg.sender][_toRemove];
        require(index != 0, "Friend do not exsist");

        _removeFriend(msg.sender, _toRemove);
        _removeFriend(_toRemove, msg.sender);
    }
    
    /**
     * @dev Returns the friends list related to the msg.sender
     */
    function getFriends() public view returns (Friend[] memory) {
        return friends[msg.sender];
    }
    
    /**
     * @dev Returns the requests list related directed to the msg.sender
     */
    function getRequests() public view returns (FriendRequest[] memory) {
        return requests[msg.sender];
    }
}