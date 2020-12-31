import { expect, assert } from 'chai';
import {
    BStableProxyContract,
    BStableProxyInstance,
    StableCoinContract,
    StableCoinInstance,
    BStableTokenForTestDEVContract,
    BStableTokenForTestDEVInstance,
} from '../build/types/truffle-types';
// Load compiled artifacts
const proxyContract: BStableProxyContract = artifacts.require('BStableProxy.sol');
const stableCoinContract: StableCoinContract = artifacts.require('StableCoin.sol');
const tokenContract: BStableTokenForTestDEVContract = artifacts.require('BStableTokenForTestDEV.sol');
import { BigNumber } from 'bignumber.js';

contract('BStable proxy', async accounts => {


    let proxyInstance: BStableProxyInstance;
    let dai: StableCoinInstance;
    let busd: StableCoinInstance;
    let usdt: StableCoinInstance;
    let btcb: StableCoinInstance;
    let renBtc: StableCoinInstance;
    let anyBtc: StableCoinInstance;
    let bst: BStableTokenForTestDEVInstance;
    let denominator = new BigNumber(10).exponentiatedBy(18);


    before('Get proxy contract instance', async () => {
        proxyInstance = await proxyContract.at('0xD655588Aa65b18566c7a3538835A42a6650dA5B7');
        let p1Info = await proxyInstance.getPoolInfo(0);
        let p2Info = await proxyInstance.getPoolInfo(1);
        dai = await stableCoinContract.at(p1Info[1][0]);
        busd = await stableCoinContract.at(p1Info[1][1]);
        usdt = await stableCoinContract.at(p1Info[1][2]);
        btcb = await stableCoinContract.at(p2Info[1][0]);
        renBtc = await stableCoinContract.at(p2Info[1][1]);
        anyBtc = await stableCoinContract.at(p2Info[1][2]);
        let tokenAddress = await proxyInstance.getTokenAddress();
        bst = await tokenContract.at(tokenAddress);
        console.log('======================================================');
        for (let i = 0; i < accounts.length; i++) {
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
            let bstBalStr = await bst.balanceOf(accounts[i]);
            console.log("BST balance: " + new BigNumber(bstBalStr).div(denominator).toFormat(18, BigNumber.ROUND_DOWN));
            console.log('======================================================');
        }
        let bstTotalSupply = await bst.totalSupply();
        console.log('BST totalSupply: ' + new BigNumber(bstTotalSupply).div(denominator).toFormat(18, BigNumber.ROUND_DOWN));
        let bstAvailableSupply = await bst.availableSupply();
        console.log('BST availableSupply: ' + new BigNumber(bstAvailableSupply).div(denominator).toFormat(18, BigNumber.ROUND_DOWN));
        let bstRate = await bst.getRate();
        console.log('BST rate: ' + new BigNumber(bstRate).div(denominator).toFormat(18, BigNumber.ROUND_DOWN));
    });


    describe('获取用户状态数据', async () => {

        it('获取数据', async () => {

        });

    });

});
