const Oracle = artifacts.require("contractAsProxyOracle");

module.exports = function (deployer) {
  deployer.deploy(Oracle);
};
