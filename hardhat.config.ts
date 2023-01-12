import { HardhatUserConfig, task } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import { ethers } from "ethers";


const HARDHAT_ACCOUNT_ETH_BALANCE = Math.pow(10, 10).toString();

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  networks: {
    hardhat: {
      accounts: {
        accountsBalance: ethers.utils.parseEther(HARDHAT_ACCOUNT_ETH_BALANCE).toString()
      }
    }
  }
};

// task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
//   const accounts = await hre.ethers.getSigners();

//   for (const account of accounts) {
//     console.log(account.address);
//   }
// });

export default config;
