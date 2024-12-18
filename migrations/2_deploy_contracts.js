const SimpleStorage = artifacts.require("FIRManagement");

module.exports = function (deployer) {
  deployer.deploy(SimpleStorage);
};
