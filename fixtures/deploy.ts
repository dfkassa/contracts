import { ethers } from "hardhat";

export async function deployFixture() {

    const RouterV1 = await ethers.getContractFactory("RouterV1");

    const DFK = await ethers.getContractFactory("DFK");
    const vDFK = await ethers.getContractFactory("vDFK");
    const mDFK = await ethers.getContractFactory("mDFK");
    const pDFK = await ethers.getContractFactory("pDFK");

    const DFKassa = await ethers.getContractFactory("DFKassa");
    const ConfigureMe = await ethers.getContractFactory("ConfigureMe");
    const Tracker =  await ethers.getContractFactory("Tracker");
    const Treasury =  await ethers.getContractFactory("Treasury");

    const routerV1 = await RouterV1.deploy();
    const dfk = await DFK.deploy();
    const pdfk = await pDFK.deploy(routerV1.address);
    const vdfk = await vDFK.deploy(routerV1.address);
    const mdfk = await mDFK.deploy(routerV1.address);
    const dfkassa = await DFKassa.deploy(routerV1.address);
    const tracker = await Tracker.deploy(routerV1.address);
    const treasury = await Treasury.deploy(routerV1.address);
    const configureMe = await ConfigureMe.deploy();


    await routerV1.init(
        dfk.address,
        mdfk.address,
        vdfk.address,
        pdfk.address,

        dfkassa.address,
        configureMe.address,
        treasury.address,
        tracker.address
    );

    console.log(`Succesfully deployed and initilized RouterV1 at ${routerV1.address}`);

    return {
        routerV1,
        dfk,
        pdfk,
        vdfk,
        mdfk,
        dfkassa,
        tracker,
        treasury,
        configureMe,
    }
}
