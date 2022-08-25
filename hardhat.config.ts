import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

require("dotenv").config();

const MUMBAI_PRIVATE_KEY = process.env.PRIVATE_KEY;

const config: HardhatUserConfig = {
  solidity: "0.8.9",
  networks: {
    rinkeby: {
      url: "https://eth-rinkeby.alchemyapi.io/v2/nZEPcQ5tOOasE4DANnzgxDDOqo6IQqWH",
      accounts: [`0x${MUMBAI_PRIVATE_KEY}`],
    },
  }
  
};

export default config;
