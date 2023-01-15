import hre, { ethers } from "hardhat";


function _fetchSecretFor(chainId: number): string {
    switch (chainId) {
        case 31337:
            return process.env.DFKASSA_CONTRACTS_HARDHAT_SECRET!
        case 5:
            return process.env.DFKASSA_CONTRACTS_ETH_GOERLI_SECRET!
    }
    throw Error(`Secret does not provided for such chain id: ${chainId}`)
}

export async function deployFixture() {
    const chainId = hre.network.config.chainId!;

    const DFK = await ethers.getContractFactory("DFK");
    const DFKassa = await ethers.getContractFactory("DFKassa");

    const dfk = await DFK.deploy();

    // TODO: secret from env
    const dfkassa = await DFKassa.deploy(
        dfk.address,
        ethers.utils.keccak256(ethers.utils.toUtf8Bytes(_fetchSecretFor(chainId)))
    );

    await dfk.deployed;
    await dfkassa.deployed;

    console.log(`[ Contract addresses ]`);
    console.log(`DFKassa: ${dfkassa.address}`);
    console.log(`DFK ${dfk.address}`);

    return {
        dfkassa,
        dfk,
    }
}
