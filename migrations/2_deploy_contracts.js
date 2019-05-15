// migrating the appropriate contracts
var MfgRole = artifacts.require("./MfgRole.sol");
var ConsumerRole = artifacts.require("./ConsumerRole.sol");
var RetailerRole = artifacts.require("./RetailerRole.sol");
var SellerRole = artifacts.require("./SellerRole.sol");
var SrvRole = artifacts.require("./SrvRole.sol");
var SupplyChain = artifacts.require("./SupplyChain.sol");

module.exports = function(deployer) {
  deployer.deploy(MfgRole);
  deployer.deploy(ConsumerRole);
  deployer.deploy(RetailerRole);
  deployer.deploy(SellerRole);
  deployer.deploy(SrvRole);
  deployer.deploy(SupplyChain);
};
