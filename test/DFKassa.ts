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
            const paymentFee = await context.dfkassa.PROTOCOL_FEES_REWARD();

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
            const paymentFee = await context.dfkassa.PROTOCOL_FEES_REWARD();

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

        it("Should revert if passed fee is less than it was expected for ERC20 payment", async function () {
            const context = await hardhatUtils.loadFixture(deployFixture);
            const gasPrice = ethers.utils.parseUnits("200", "gwei");
            const paymentFee = await context.dfkassa.PROTOCOL_FEES_REWARD();

            const [visitor, merchant] = await ethers.getSigners();

            await expect(context.dfkassa.pay(
                merchant.address,
                context.dfkassa.address,
                1000,
                0,
                { value: paymentFee.mul(gasPrice).sub(1), gasPrice: gasPrice }
            )).to.be.revertedWith(
                "Passed value should be greater or equal required protocol fee"
            );
        });

        it("Should revert if passed fee is less than it was expected for ether payment", async function () {
            const context = await hardhatUtils.loadFixture(deployFixture);
            const gasPrice = ethers.utils.parseUnits("200", "gwei");
            const paymentFee = await context.dfkassa.PROTOCOL_FEES_REWARD();
            const paymentValue = ethers.utils.parseEther("1");

            const [visitor, merchant] = await ethers.getSigners();

            await expect(context.dfkassa.pay(
                merchant.address,
                ethers.constants.AddressZero,
                paymentValue,
                0,
                { value: paymentValue.add(paymentFee.mul(gasPrice).sub(1)), gasPrice: gasPrice }
            )).to.be.revertedWith(
                "Passed value should be greater or equal payment amount + protocol fee"
            );
        });

        it("Should emit an event with actual args", async function () {
            const context = await hardhatUtils.loadFixture(deployFixture);
            const gasPrice = ethers.utils.parseUnits("200", "gwei");
            const paymentFee = await context.dfkassa.PROTOCOL_FEES_REWARD();

            const [visitor, merchant] = await ethers.getSigners();

            const transferedValue = ethers.utils.parseEther("10");
            const txValue = paymentFee.mul(gasPrice).add(transferedValue);

            await expect(
                context.dfkassa.pay(
                    merchant.address,
                    ethers.constants.AddressZero,
                    transferedValue,
                    123123123,
                    {
                        value: txValue,
                        gasPrice: gasPrice
                    }
                )
            ).to
                .emit(context.dfkassa, "NewPayment")
                .withArgs(
                    123123123,
                    merchant.address,
                    transferedValue,
                    ethers.constants.AddressZero,
                    0,
                    paymentFee.mul(gasPrice)
                )
            ;

        });

        it("Should give the cashback for merchant for recieving DFK", async function () {
            const context = await hardhatUtils.loadFixture(deployFixture);
            const gasPrice = ethers.utils.parseUnits("200", "gwei");
            const paymentFee = await context.dfkassa.PROTOCOL_FEES_REWARD();
            const paymentDiscount = (await context.dfkassa.DFK_PAYMENT_DISCOUNT()).mul(gasPrice);
            const merchantCashback = (await context.dfkassa.DFK_RECIEVING_CASHBACK()).mul(gasPrice);

            const [owner, visitor, merchant] = await ethers.getSigners();

            const previousMerchantBalance = await merchant.getBalance();

            await context.dfk.transfer(
                visitor.address, 1000,
            );

            const previousOwnerBalance = await owner.getBalance();
            await context.dfk.connect(visitor).approve(context.dfkassa.address, 1000);

            await context.dfkassa.connect(visitor).pay(
                merchant.address,
                context.dfk.address,
                1000,
                0,
                { value: paymentFee.mul(gasPrice).sub(paymentDiscount), gasPrice: gasPrice }
            );

            expect(
                await owner.getBalance()
            ).to.be.eq(
                previousOwnerBalance.add(
                    paymentFee
                    .mul(gasPrice)
                    .sub(paymentDiscount)
                    .sub(merchantCashback)
                )
            );
            expect(
                await merchant.getBalance()
            ).to.be.eq(previousMerchantBalance.add(merchantCashback));
        });
    })

    describe("SetProtoRewardsReciever", function () {
        it("Should revert when trying to change rewards claimer with invalid sign", async function () {
            // TODO
        })
        it("Should revert when trying to change rewards claimer with invalid secret", async function () {
            // TODO
        })
    })

})
