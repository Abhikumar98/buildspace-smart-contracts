require('@nomiclabs/hardhat-waffle');
require('dotenv').config();

module.exports = {
  solidity: '0.8.0',
  networks: {
    rinkeby: {
      url: process.env.RINKEBY_STAGING_ALCHEMY_KEY,
      accounts: [process.env.RINKEBY_PRIVATE_KEY],
    },
  },
};