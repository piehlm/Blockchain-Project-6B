pragma solidity ^0.4.24;

// Import the library 'Roles'
import "./Roles.sol";

// Define a contract 'MfgRole' to manage this role - add, remove, check
contract MfgRole {
  using Roles for Roles.Role;

  // Define 2 events, one for Adding, and other for Removing
  event MfgAdded(address indexed account);
  event MfgRemoved(address indexed account);

  // Define a struct 'mfg' by inheriting from 'Roles' library, struct Role
  Roles.Role private mfg;

  // In the constructor make the address that deploys this contract the 1st manufacturer
  constructor() public {
    _addMfg(msg.sender);
  }

  // Define a modifier that checks to see if msg.sender has the appropriate role
  modifier onlyMfg() {
    require(isMfg(msg.sender));
    _;
  }

  // Define a function 'isMfg' to check this role
  function isMfg(address account) public view returns (bool) {
    return mfg.has(account);
  }

  // Define a function 'addMfg' that adds this role
  function addMfg(address account) public onlyMfg {
    _addMfg(account);
  }

  // Define a function 'renounceMfg' to renounce this role
  function renounceMfg() public {
    _removeMfg(msg.sender);
  }

  // Define an internal function '_addMfg' to add this role, called by 'addMfg'
  function _addMfg(address account) internal {
    mfg.add(account);
    emit MfgAdded(account);
  }

  // Define an internal function '_removeMfg' to remove this role, called by 'removeMfg'
  function _removeMfg(address account) internal {
    mfg.remove(account);
    emit MfgRemoved(account);
  }
}