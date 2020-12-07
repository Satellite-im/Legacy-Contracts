pragma solidity >=0.4.22 <0.7.0;

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
}