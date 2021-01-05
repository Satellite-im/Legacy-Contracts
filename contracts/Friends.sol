// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.8.0;
pragma experimental ABIEncoderV2;

/**
 * @title FriendRequester
 * @dev Maps friend requests along with associated threadIDs
 */
contract Friends {

    struct Friend {
        address dweller; // Address of the friend
        bytes32 threadHash1; // Part 1 of the convorsation ThreadID
        bytes32 threadHash2; // Part 2 of the convorsation ThreadID
    }

    struct FriendRequest {
        uint id; // ID of the friend request
        bool active; // Is the friend request still pending
        bool accepted; // Has the friend request  been accepted
        address sender; // The address of the user whom sent the request
        address reciver; // The address of the person they are request to friend with
        bytes32 threadHash1; // Part 1 of the convorsation ThreadID
        bytes32 threadHash2; // Part 2 of the convorsation ThreadID
    }

    // We only expose who the request was sent to
    event FriendRequestSent(address indexed sentTo);
    // Emitted when a user removes a friend
    event FriendRemoved(address indexed friendRemoved);

    // List of requests a particular address has recieved
    mapping(address => uint[]) private recievedRequests;
    // Mapping of requests to IDs a particular address has sent
    // This is used to insure an address does not send multiple
    // friend requests to a user
    mapping(address => mapping(address => uint)) private sentRequests;
    // List of all friend requests
    FriendRequest[] private requests;
    // Mapping of all friends a particular address has
    mapping(address => Friend[]) private friends;

    /**
     * @dev Create a new Friends contract
     */
    constructor() {
        // Prevents multiple friend requets from first sender.
        // since we check against zero, here we're just reserving
        // the 0 ID slot.
        requests.push(FriendRequest(
            0,
            true,
            false,
            address(0x0),
            address(0x0),
            bytes32(0),
            bytes32(0)
        ));
    }

    /** 
     * @dev Get all the friend requests you have recieved
     * @return list of friend IDs
     */
    function getRequests()
        public
        view
        returns (uint[] memory)
    {
        return recievedRequests[msg.sender];
    }
    
    
    /** 
     * @dev Get a specified request by ID
     * @return Friend request at specified id
     */
    function getRequest(uint id)
        public
        view
        returns (FriendRequest memory)
    {
        FriendRequest memory fr = requests[id];
        return fr;
    }
    
    /** 
     * @dev Get all the friends you have
     * @return list of Friends
     */
    function getFriends() 
        public
        view
        returns (Friend[] memory) 
    {
        return friends[msg.sender];
    }

    /** 
     * @dev Make a new friend request to a user
     * @param to Address to send the friend request to
     * @param thread bytes list containing split threadID hash
     */
    function makeRequest(address to, bytes32[2] memory thread) 
        public 
    {
        require(to != msg.sender, "You can't friend yourself.");
        require(sentRequests[msg.sender][to] == 0, "You already sent a request to this user.");
        FriendRequest memory fr = FriendRequest(
            requests.length,
            true,
            false,
            msg.sender,
            to,
            thread[0],
            thread[1]
        );
        requests.push(fr);
        // Send new request
        recievedRequests[to].push(requests.length - 1);
        // Add request to sent requests
        sentRequests[msg.sender][to] = requests.length - 1;
        // Emit request sent event
        emit FriendRequestSent(to);
    }

    /**
     * @dev Accept a friend request by ID
     * @param id ID of the friend request to accept
     */
    function acceptRequest(uint id) public {
        FriendRequest memory fr = requests[id];
        require(fr.reciver == msg.sender, "This request isn't yours to accept");
        // The requests lifecycle is over
        fr.active = false;
        // Accept the request so the sender knows we're friends.
        fr.accepted = true;
        requests[id] = fr;
        // Add friends for the users
        friends[msg.sender].push(Friend(
            fr.sender,
            fr.threadHash1,
            fr.threadHash2
        ));
        friends[fr.sender].push(Friend(
            msg.sender,
            fr.threadHash1,
            fr.threadHash2
        ));
    }

    /**
     * @dev Deny a friend request by ID
     * @param id ID of the friend request to deny
     */
    function denyRequest(uint id)
        public
    {
        FriendRequest memory fr = requests[id];
        require(fr.reciver == msg.sender, "You can't deny other people's requests.");
        require(fr.active == true, "The friend request is no loger active.");
        // The requests lifecycle is over
        fr.active = false;
        requests[id] = fr;
        // Cancel the pending request so they can send another in the future
        sentRequests[fr.sender][msg.sender] = 0;
    }

    /**
     * @dev Remove a friend by address
     * @param dweller address of the friend to remove
     */
    function removeFriend(address dweller) 
        public
    {
        // Locate friends this sender has
        Friend[] storage frs = friends[msg.sender];
        // Track index of found friends
        uint indx;
        // Iterate friends to find index of friend to remove
        for (uint i = 0; i < frs.length; i++) {
            if (frs[i].dweller == dweller) {
                indx = i;
                break;
            }
        }
        // If the friend is not the last in the list,
        if (indx < frs.length - 1) {
          // shift the last item into it's place.
          frs[indx] = frs[frs.length - 1];
        }
        // Delete the last item in the list.
        delete frs[frs.length - 1];
        // Emit friend removed
        emit FriendRemoved(dweller);
    }
}