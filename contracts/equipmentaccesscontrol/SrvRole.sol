pragma solidity ^0.4.24;

// Import the library 'Roles'
import "./Roles.sol";

// Define a contract 'SrvRole' to manage this role - add, remove, check
contract SrvRole {
  using Roles for Roles.Role;

  // Define 2 events, one for Adding, and other for Removing
  event SrvAdded(address indexed account);
  event SrvRemoved(address indexed account);

  // Define a struct 'srv' by inheriting from 'Roles' library, struct Role
  Roles.Role private srv;

  // In the constructor make the address that deploys this contract the 1st service shop
  constructor() public {
    _addSrv(msg.sender);
  }

  // Define a modifier that checks to see if msg.sender has the appropriate role
  modifier onlySrv() {
    require(isSrv(msg.sender));
    _;
  }

  // Define a function 'isSrv' to check this role
  function isSrv(address account) public view returns (bool) {
    return srv.has(account);
  }

  // Define a function 'addSrv' that adds this role
  function addSrv(address account) public onlySrv {
    _addSrv(account);
  }

  // Define a function 'renounceSrv' to renounce this role
  function renounceSrv() public {
    _removeSrv(msg.sender);
  }

  // Define an internal function '_addSrv' to add this role, called by 'addSrv'
  function _addSrv(address account) internal {
    srv.add(account);
    emit SrvAdded(account);
  }

  // Define an internal function '_removeSrv' to remove this role, called by 'removeSrv'
  function _removeSrv(address account) internal {
    srv.remove(account);
    emit SrvRemoved(account);
  }
}