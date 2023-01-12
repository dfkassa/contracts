import * as hardhatUtils from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

import { deployFixture } from "../fixtures/deploy";



describe("DFKassa", function () {
    describe("Construct", function () {
        it("Should successfully deployed", async function () {
            const context = await hardhatUtils.loadFixture(deployFixture);
        });
    })
    describe("Pay", function () {
        it("Should transfer passed ERC20 assets", async function () {
            const context = await hardhatUtils.loadFixture(deployFixture);
            const gasPrice = ethers.utils.parseUnits("200", "gwei");
            const paymentFee = await context.configureMe.visitorTxGasFee();

            const [visitor, merchant] = await ethers.getSigners();

            await context.dfk.approve(context.dfkassa.address, 1000);

            const visitorDFKBalanceBefore = await context.dfk.balanceOf(visitor.address);
            const merchantDFKBalanceBefore = await context.dfk.balanceOf(merchant.address);

            await context.dfkassa.pay(
                merchant.address,
                context.dfk.address,
                1000,
                0,
                { value: paymentFee.mul(gasPrice), gasPrice: gasPrice }
            );

            expect(await context.dfk.balanceOf(visitor.address)).to.eq(
                visitorDFKBalanceBefore.sub(1000)
            )
            expect(await context.dfk.balanceOf(merchant.address)).to.eq(
                merchantDFKBalanceBefore.add(1000)
            )
        });

        it("Should transfer passed Ethers", async function () {
            const context = await hardhatUtils.loadFixture(deployFixture);
            const gasPrice = ethers.utils.parseUnits("200", "gwei");
            const paymentFee = await context.configureMe.visitorTxGasFee();

            const [visitor, merchant] = await ethers.getSigners();

            const previousVisitorBalance = await visitor.getBalance();
            const previousMerchantBalance = await merchant.getBalance();
            const transferedValue = ethers.utils.parseEther("10");
            const txValue = paymentFee.mul(gasPrice).add(transferedValue);

            await context.dfkassa.pay(
                merchant.address,
                ethers.constants.AddressZero,
                transferedValue,
                0,
                {
                    value: txValue,
                    gasPrice: gasPrice
                }
            );
            expect(previousMerchantBalance.add(transferedValue)).to.be.eq(
                await merchant.getBalance()
            )

        });

        it("Should revert if passed fee is less than it was expected", async function () {
            const context = await hardhatUtils.loadFixture(deployFixture);
            const gasPrice = ethers.utils.parseUnits("200", "gwei");
            const paymentFee = await context.configureMe.visitorTxGasFee();

            const [visitor, merchant] = await ethers.getSigners();

            await context.dfk.approve(context.dfkassa.address, 1000);

            await expect(context.dfkassa.pay(
                merchant.address,
                context.pdfk.address,
                1000,
                0,
                { value: paymentFee.mul(gasPrice).sub(1), gasPrice: gasPrice }
            )).to.be.revertedWith(
                "Provide protocol fee to complete the payment"
            );
        });

        // it("Should save payment details", async function () {
        //     const context = await hardhatUtils.loadFixture(deployFixture);
        //     const gasPrice = ethers.utils.parseUnits("200", "gwei");
        //     const paymentFee = await context.configureMe.visitorTxGasFee();

        //     const [visitor, merchant] = await ethers.getSigners();

        //     await context.dfk.approve(context.dfkassa.address, 1000);
        //     await context.dfkassa.pay(
        //         merchant.address,
        //         context.dfk.address,
        //         1000,
        //         0,
        //         { value: paymentFee.mul(gasPrice), gasPrice: gasPrice }
        //     );

        //     const payment = await context.dfkassa.payments(3);

        //     expect(payment.amount).to.eq(ethers.BigNumber.from("1000"));
        //     expect(payment.token).to.eq(context.dfk.address);
        //     expect(payment.from).to.eq(visitor.address);
        //     expect(payment.to).to.eq(merchant.address);
        //     expect(payment.payload).to.eq(ethers.constants.Zero);
        // });

        it("Should revert because passed value does not equal fee + amount", async function () {
            const context = await hardhatUtils.loadFixture(deployFixture);
            const gasPrice = ethers.utils.parseUnits("200", "gwei");
            const paymentFee = await context.configureMe.visitorTxGasFee();

            const [visitor, merchant] = await ethers.getSigners();

            await expect(context.dfkassa.pay(
                merchant.address,
                ethers.constants.AddressZero,
                ethers.utils.parseEther("10"),
                0,
                { value: paymentFee.mul(gasPrice).add(ethers.utils.parseEther("10").sub(1)), gasPrice: gasPrice }
            )).to.be.revertedWith(
                "Payment amount + protocol fee should be less or equal passed value"
            );
        });
    })

})
