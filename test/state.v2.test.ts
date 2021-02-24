import { expect, assert } from 'chai';
import {
    BStableProxyV2Contract,
    BStableProxyV2Instance,
    StableCoinContract,
    StableCoinInstance,
    BStableTokenV2Contract,
    BStableTokenV2Instance,
    BStablePoolContract,
    BStablePoolInstance,
} from '../build/types/truffle-types';
// Load compiled artifacts
const proxyContract: BStableProxyV2Contract = artifacts.require('BStableProxyV2.sol');
const stableCoinContract: StableCoinContract = artifacts.require('StableCoin.sol');
const tokenContract: BStableTokenV2Contract = artifacts.require('BStableTokenV2.sol');
const poolContract: BStablePoolContract = artifacts.require('BStablePool.sol');
import { BigNumber } from 'bignumber.js';
import { config } from './config'

contract('BStable proxy', async accounts => {


    let proxyInstance: BStableProxyV2Instance;
    let dai: StableCoinInstance;
    let busd: StableCoinInstance;
    let usdt: StableCoinInstance;
    let btcb: StableCoinInstance;
    let renBtc: StableCoinInstance;
    let anyBtc: StableCoinInstance;
    let bst: BStableTokenV2Instance;
    let p1: BStablePoolInstance;
    let p2: BStablePoolInstance;
    let denominator = new BigNumber(10).exponentiatedBy(18);


    before('Get proxy contract instance', async () => {
        proxyInstance = await proxyContract.at(config.proxyAddress);
        let p1Info = await proxyInstance.getPoolInfo(0);
        let p2Info = await proxyInstance.getPoolInfo(1);
        p1 = await poolContract.at(p1Info[0]);
        p2 = await poolContract.at(p2Info[0]);
        dai = await stableCoinContract.at(p1Info[1][0]);
        busd = await stableCoinContract.at(p1Info[1][1]);
        usdt = await stableCoinContract.at(p1Info[1][2]);
        btcb = await stableCoinContract.at(p2Info[1][0]);
        renBtc = await stableCoinContract.at(p2Info[1][1]);
        anyBtc = await stableCoinContract.at(p2Info[1][2]);
        let tokenAddress = await proxyInstance.getTokenAddress();
        bst = await tokenContract.at(tokenAddress);
        console.log('======================================================');
    });


    describe('获取用户状态数据', async () => {

        it('获取数据', async () => {
            for (let i = 0; i < accounts.length; i++) {
                console.log('accounts[ ' + i + ' ]');
                console.log('account address: ' + accounts[i]);
                let daiBalStr = await dai.balanceOf(accounts[i]);
                console.log("DAI balance: " + new BigNumber(daiBalStr).div(denominator).toFormat(18, BigNumber.ROUND_DOWN));
                let busdBalStr = await busd.balanceOf(accounts[i]);
                console.log("BUSD balance: " + new BigNumber(busdBalStr).div(denominator).toFormat(18, BigNumber.ROUND_DOWN));
                let usdtBalStr = await usdt.balanceOf(accounts[i]);
                console.log("USDT balance: " + new BigNumber(usdtBalStr).div(denominator).toFormat(18, BigNumber.ROUND_DOWN));
                let btcbBalStr = await btcb.balanceOf(accounts[i]);
                console.log("BTCB balance: " + new BigNumber(btcbBalStr).div(denominator).toFormat(18, BigNumber.ROUND_DOWN));
                let renBtcBalStr = await renBtc.balanceOf(accounts[i]);
                console.log("renBTC balance: " + new BigNumber(renBtcBalStr).div(denominator).toFormat(18, BigNumber.ROUND_DOWN));
                let anyBtcBalStr = await anyBtc.balanceOf(accounts[i]);
                console.log("anyBTC balance: " + new BigNumber(anyBtcBalStr).div(denominator).toFormat(18, BigNumber.ROUND_DOWN));
                let userInfo1 = await proxyInstance.getUserInfo(0, accounts[i]);
                let userInfo2 = await proxyInstance.getUserInfo(1, accounts[i]);
                let lp1Bal = await p1.balanceOf(accounts[i]);
                console.log('LP1: ' + new BigNumber(lp1Bal).div(denominator).toFormat(18, BigNumber.ROUND_DOWN));
                console.log('Staking LP1: ' + new BigNumber(userInfo1[0]).div(denominator).toFormat(18, BigNumber.ROUND_DOWN));
                let lp2Bal = await p2.balanceOf(accounts[i]);
                console.log('LP2: ' + new BigNumber(lp2Bal).div(denominator).toFormat(18, BigNumber.ROUND_DOWN));
                console.log('Staking LP2: ' + new BigNumber(userInfo2[0]).div(denominator).toFormat(18, BigNumber.ROUND_DOWN));
                let bstBalStr = await bst.balanceOf(accounts[i]);
                console.log("BST balance: " + new BigNumber(bstBalStr).div(denominator).toFormat(18, BigNumber.ROUND_DOWN));
                let pending1 = await proxyInstance.pendingReward(0, accounts[i]);
                console.log("p1 Share pending reward: " + new BigNumber(pending1).div(denominator).toFormat(18, BigNumber.ROUND_DOWN));
                let pending2 = await proxyInstance.pendingReward(1, accounts[i]);
                console.log("p2 Share pending reward: " + new BigNumber(pending2).div(denominator).toFormat(18, BigNumber.ROUND_DOWN));
                console.log('======================================================');
            }
            let bstTotalSupply = await bst.totalSupply();
            console.log('BST totalSupply: ' + new BigNumber(bstTotalSupply).div(denominator).toFormat(18, BigNumber.ROUND_DOWN));
            let devAmtStr = await bst.balanceOf(accounts[0]);
            console.log('Token dev get: ' + new BigNumber(devAmtStr).div(denominator).toFormat(18, BigNumber.ROUND_DOWN))
            let p1AdminFee_0 = await p1.admin_balances(0);
            console.log("P1 admin fee 0: " + new BigNumber(p1AdminFee_0).div(denominator).toFormat(4, 1));
            let p1AdminFee_1 = await p1.admin_balances(1);
            console.log("P1 admin fee 1: " + new BigNumber(p1AdminFee_1).div(denominator).toFormat(4, 1));
            let p1AdminFee_2 = await p1.admin_balances(2);
            console.log("P1 admin fee 2: " + new BigNumber(p1AdminFee_2).div(denominator).toFormat(4, 1));
            let p2AdminFee_0 = await p2.admin_balances(0);
            console.log("P2 admin fee 0: " + new BigNumber(p2AdminFee_0).div(denominator).toFormat(4, 1));
            let p2AdminFee_1 = await p2.admin_balances(1);
            console.log("P2 admin fee 1: " + new BigNumber(p2AdminFee_1).div(denominator).toFormat(4, 1));
            let p2AdminFee_2 = await p1.admin_balances(2);
            console.log("P2 admin fee 2: " + new BigNumber(p2AdminFee_2).div(denominator).toFormat(4, 1));
            let p1VolumeStr = await p1.getVolume();
            let p2VolumeStr = await p2.getVolume();
            let p1Volume = new BigNumber(p1VolumeStr).div(denominator);
            let p2Volume = new BigNumber(p2VolumeStr).div(denominator);
            console.log('Pool1 Volume: ' + p1Volume.toFormat(18, 1));
            console.log('Pool2 Volume: ' + p2Volume.toFormat(18, 1));
            let p1TotalSupplyStr = await p1.totalSupply();
            let p2TotalSupplyStr = await p2.totalSupply();
            let p1TotalSupply = new BigNumber(p1TotalSupplyStr).div(denominator);
            let p2TotalSupply = new BigNumber(p2TotalSupplyStr).div(denominator);
            console.log('Pool1 totalSupply: ' + p1TotalSupply.toFormat(18, 1));
            console.log('Pool2 totalSupply: ' + p2TotalSupply.toFormat(18, 1));
            let p1FeeStr = await p1.getFee();
            let p2FeeStr = await p2.getFee();
            let p1AdminFeeStr = await p1.getAdminFee();
            let p2AdminFeeStr = await p2.getAdminFee();
            let p1Fee = new BigNumber(p1FeeStr).div(new BigNumber(10).exponentiatedBy(10));
            let p2Fee = new BigNumber(p2FeeStr).div(new BigNumber(10).exponentiatedBy(10));
            console.log('Pool1 Fee: ' + p1Fee.toFormat(18, 1));
            console.log('Pool2 Fee: ' + p2Fee.toFormat(18, 1));
            let p1AdminFee = new BigNumber(p1AdminFeeStr).div(new BigNumber(10).exponentiatedBy(10));
            let p2AdminFee = new BigNumber(p2AdminFeeStr).div(new BigNumber(10).exponentiatedBy(10));
            console.log('Pool1 adminFee: ' + p1AdminFee.toFormat(18, 1));
            console.log('Pool2 adminFee: ' + p2AdminFee.toFormat(18, 1));
            let p1InterestRate = p1Volume.multipliedBy(p1Fee).multipliedBy(new BigNumber(1).minus(p1AdminFee)).div(p1TotalSupply);
            let p2InterestRate = p2Volume.multipliedBy(p2Fee).multipliedBy(new BigNumber(1).minus(p2AdminFee)).div(p2TotalSupply);
            console.log('Pool1 interest rate: ' + p1InterestRate.toFormat(18, 1));
            console.log('Pool2 interest rate: ' + p2InterestRate.toFormat(18, 1));
            let p1APY = new BigNumber(1).plus(p1InterestRate.div(365)).exponentiatedBy(365).minus(1);
            let p2APY = new BigNumber(1).plus(p2InterestRate.div(365)).exponentiatedBy(365).minus(1);
            console.log('Pool1 APY: ' + p1APY.toFormat(4, 1));
            console.log('Pool2 APY: ' + p2APY.toFormat(4, 1));
            let devAddress = await proxyInstance.getDevAddress();
            console.log('Dev address: ' + devAddress);
            let startBlock = await proxyInstance.getStartBlock();
            console.log('Start Block: ' + startBlock);
            let bonusEndBlock = await proxyInstance.getBonusEndBlock();
            console.log('Bonus End Block: ' + bonusEndBlock);
            let tokenPerBlockStr = await proxyInstance.getTokenPerBlock();
            let tokenPerBlock = new BigNumber(tokenPerBlockStr).div(denominator);
            console.log('Token per Block: ' + tokenPerBlock.toFormat(2, 1));
            console.log('======================================================');
            console.log('Pool1: ' + p1.address);
            console.log('dai: ' + dai.address);
            console.log('xusd: ' + busd.address);
            console.log('usdt: ' + usdt.address);
            console.log('Pool2: ' + p2.address);
            console.log('renBtc: ' + renBtc.address);
            console.log('xbtc: ' + btcb.address);
            console.log('anyBtc: ' + anyBtc.address);
            console.log('Token address: ' + bst.address);
        }).timeout(3600 * 1000);

    });

});
