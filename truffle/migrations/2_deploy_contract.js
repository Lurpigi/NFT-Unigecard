require("dotenv").config();

const { deployProxy } = require("@openzeppelin/truffle-upgrades");
const Oracle = artifacts.require("InfUnigeNFT");

module.exports = async function (deployer) {
  const subscriptionId = process.env.VRF_SUBSCRIPTION_ID;
  await deployProxy(Oracle, [subscriptionId], {
    deployer,
    initializer: "initialize",
  });
};