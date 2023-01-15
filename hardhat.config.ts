import { HardhatUserConfig, task } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import { ethers } from "ethers";

const dotenv = require("dotenv");
dotenv.config({ path: __dirname + "/.env" });


const HARDHAT_ACCOUNT_ETH_BALANCE = Math.pow(10, 10).toString();

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
          enabled: true,
          runs: 1000,
          details: { yul: false },
      },
    }
  },
  networks: {
    hardhat: {
      chainId: 31337,
      accounts: {
        accountsBalance: ethers.utils.parseEther(HARDHAT_ACCOUNT_ETH_BALANCE).toString()
      }
    },
    goerli: {
      chainId: 5,
      url: process.env.DFKASSA_CONTRACTS_GOERLI_RPC_URL!,
      accounts: [process.env.DFKASSA_CONTRACTS_PK!],
    },
  },
  etherscan: {
    apiKey: process.env.DFKASSA_CONTRACTS_ETHERSCAN_API_KEY!,
  },
};


export default config;
