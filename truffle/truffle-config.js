require('dotenv').config();
const HDWalletProvider = require('@truffle/hdwallet-provider');

module.exports = {
  networks: {
    sepolia: {
      provider: () =>
        new HDWalletProvider(
          [process.env.PRIVATE_KEY],
          `https://eth-sepolia.g.alchemy.com/v2/${process.env.ALCHEMY_KEY}`
        ),
      network_id: 11155111,
      gas: 4_000_000, // 4M
      gasPrice: 20_000_000_000, // 20 gwei
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true,
    },
  },
  compilers: {
    solc: {
      version: "0.8.29",
    },
  },
  plugins: ['truffle-plugin-verify'],
  api_keys: {
    etherscan: process.env.ETHERSCAN_API_KEY,
  }
};
