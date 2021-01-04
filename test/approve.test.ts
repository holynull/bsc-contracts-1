import { expect, assert } from 'chai';
import {
    BStableProxyContract,
    BStableProxyInstance,
    StableCoinContract,
    StableCoinInstance,
    BStableTokenForTestDEVContract,
    BStableTokenForTestDEVInstance,
    BStablePoolContract,
    BStablePoolInstance,
} from '../build/types/truffle-types';
// Load compiled artifacts
const proxyContract: BStableProxyContract = artifacts.require('BStableProxy.sol');
const stableCoinContract: StableCoinContract = artifacts.require('StableCoin.sol');
const tokenContract: BStableTokenForTestDEVContract = artifacts.require('BStableTokenForTestDEV.sol');
const poolContract: BStablePoolContract = artifacts.require('BStablePool.sol');
import { BigNumber } from 'bignumber.js';
import { config } from './config'

contract('BStable proxy', async accounts => {

    let proxyInstance: BStableProxyInstance;
    let dai: StableCoinInstance;
    let busd: StableCoinInstance;
    let usdt: StableCoinInstance;
    let btcb: StableCoinInstance;
    let renBtc: StableCoinInstance;
    let anyBtc: StableCoinInstance;
    let bst: BStableTokenForTestDEVInstance;
    let p1: BStablePoolInstance;
    let p2: BStablePoolInstance;
    let denominator = new BigNumber(10).exponentiatedBy(18);
    let maxApproveAmt = new BigNumber(2).exponentiatedBy(255);


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

    });


    describe('测试approve', async () => {

        it('流动性以及6个币最大approve', async () => {
            for (let i = 0; i < accounts.length; i++) {
                await p1.approve(proxyInstance.address, maxApproveAmt.toFixed(0, BigNumber.ROUND_DOWN), { from: accounts[i] });
                await p2.approve(proxyInstance.address, maxApproveAmt.toFixed(0, BigNumber.ROUND_DOWN), { from: accounts[i] });
                await dai.approve(proxyInstance.address, maxApproveAmt.toFixed(0, BigNumber.ROUND_DOWN), { from: accounts[i] });
                await busd.approve(proxyInstance.address, maxApproveAmt.toFixed(0, BigNumber.ROUND_DOWN), { from: accounts[i] });
                await usdt.approve(proxyInstance.address, maxApproveAmt.toFixed(0, BigNumber.ROUND_DOWN), { from: accounts[i] });
                await btcb.approve(proxyInstance.address, maxApproveAmt.toFixed(0, BigNumber.ROUND_DOWN), { from: accounts[i] });
                await renBtc.approve(proxyInstance.address, maxApproveAmt.toFixed(0, BigNumber.ROUND_DOWN), { from: accounts[i] });
                await anyBtc.approve(proxyInstance.address, maxApproveAmt.toFixed(0, BigNumber.ROUND_DOWN), { from: accounts[i] });
                await dai.approve(p1.address, maxApproveAmt.toFixed(0, BigNumber.ROUND_DOWN), { from: accounts[i] });
                await busd.approve(p1.address, maxApproveAmt.toFixed(0, BigNumber.ROUND_DOWN), { from: accounts[i] });
                await usdt.approve(p1.address, maxApproveAmt.toFixed(0, BigNumber.ROUND_DOWN), { from: accounts[i] });
                await btcb.approve(p1.address, maxApproveAmt.toFixed(0, BigNumber.ROUND_DOWN), { from: accounts[i] });
                await renBtc.approve(p1.address, maxApproveAmt.toFixed(0, BigNumber.ROUND_DOWN), { from: accounts[i] });
                await anyBtc.approve(p1.address, maxApproveAmt.toFixed(0, BigNumber.ROUND_DOWN), { from: accounts[i] });
                await dai.approve(p2.address, maxApproveAmt.toFixed(0, BigNumber.ROUND_DOWN), { from: accounts[i] });
                await busd.approve(p2.address, maxApproveAmt.toFixed(0, BigNumber.ROUND_DOWN), { from: accounts[i] });
                await usdt.approve(p2.address, maxApproveAmt.toFixed(0, BigNumber.ROUND_DOWN), { from: accounts[i] });
                await btcb.approve(p2.address, maxApproveAmt.toFixed(0, BigNumber.ROUND_DOWN), { from: accounts[i] });
                await renBtc.approve(p2.address, maxApproveAmt.toFixed(0, BigNumber.ROUND_DOWN), { from: accounts[i] });
                await anyBtc.approve(p2.address, maxApproveAmt.toFixed(0, BigNumber.ROUND_DOWN), { from: accounts[i] });
            }
        });

    });

});
