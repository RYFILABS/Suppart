var SuppartToken = artifacts.require("SuppartToken");

module.exports = function(deployer) {
  // Arguments are: contract, initialSupply
  deployer.deploy(SuppartToken, 1000);
};