import { ethers } from "hardhat";
import { deployFixture } from "../fixtures/deploy";


// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
deployFixture().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
