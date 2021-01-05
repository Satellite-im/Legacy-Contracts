// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 < 0.8.0;

import "./DwellerID.sol";
import "./Server.sol";

/** 
 * @title Vault74Registry
 * @dev Implements storage and assignment of Vault74 DwellerIDs
 */
contract Vault74Registry {
    mapping(address => address) internal dwellers;

    /**
     * @dev Create a new dweller identification contract
     * @param name The name this dweller wishes to go by
     */
    function createDweller(bytes32 name) 
        public 
        returns(address newDwellerId) 
    {
        address sender = msg.sender;
        // Make sure this user doesn't already have an ID assigned.
        assert(dwellers[sender] == address(0));
        // Create a new ID for the sender.
        DwellerID dwellerId = new DwellerID(name, sender);
        dwellers[sender] = address(dwellerId);
        return address(dwellerId);
    }

    /**
     * @dev Create a new Server contract and assign the sender as owner
     * @param name Human readable name of the server
     */
    function createServer(bytes32 name)
        public
        returns(address serverAddress)
    {
        require(dwellers[msg.sender] != address(0), "Please register an ID first.");
        DwellerID dweller = DwellerID(dwellers[msg.sender]);
        Server server = new Server(name, msg.sender);
        serverAddress = address(server);
        dweller.joinServer(serverAddress);
    }

     /**
     * @dev Get an identifiaction contract for a given dweller
     * @param dweller The address of the dweller we're looking up
     */
    function getDwellerId(address dweller)
        public
        view
        returns(address dwellerId)
    {
        return dwellers[dweller];
    }

    /**
     * @dev If a user is not already a part of a server
     * attempt to join a new server
     * @param _server Address pointing to server contract to join
     */
    function joinServer(address _server) 
        public
    {
        require(dwellers[msg.sender] != address(0), "Please register an ID first.");
        Server server = Server(_server);
        server.join(msg.sender);
        DwellerID dweller = DwellerID(dwellers[msg.sender]);
        address[] memory servers = dweller.getServers();
        for (uint i=0; i<servers.length; i++) {
          require(servers[i] != _server, "Dweller is already in this server.");
        }
        dweller.joinServer(_server);
    }

    /**
     * @dev If a user is a part of a server try to leave it
     * @param _server Address pointing to server contract to leave
     */
    function leaveServer(address _server) 
        public
    {
        require(dwellers[msg.sender] != address(0), "Please register an ID first.");
        DwellerID dweller = DwellerID(dwellers[msg.sender]);
        address[] memory servers = dweller.getServers();
        bool inServer = false;
        for (uint i=0; i<servers.length; i++) {
            if (servers[i] == _server) {
                inServer = true;
            }
        }
        require(inServer, "Dweller is not in this server.");
        dweller.leaveServer(_server);
        Server server = Server(_server);
        address[] memory members = server.getMembers();
        uint indx;
        for (uint i=0; i<members.length; i++) {
            if (members[i] == msg.sender) {
                indx = i;
            }
        }
        server.leave(indx);
    }
}