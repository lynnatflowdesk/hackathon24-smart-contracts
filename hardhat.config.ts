import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import dotenv from "dotenv";

dotenv.config();

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.20", // Specify the Solidity version
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    // Ethereum Mainnet
    mainnet: {
      url: `https://mainnet.infura.io/v3/${process.env.INFURA_PROJECT_ID}`,
      // @ts-ignore
      accounts: [process.env.MAINNET_PRIVATE_KEY],
    },
    // Gnosis Chain (formerly xDai)
    gnosis: {
      url: "https://rpc.gnosischain.com",
      // @ts-ignore
      accounts: [process.env.GNOSIS_PRIVATE_KEY],
    },
    // You can add more networks as needed
  },
  etherscan: {
    // Etherscan API key for verifying contracts
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};

export default config;
