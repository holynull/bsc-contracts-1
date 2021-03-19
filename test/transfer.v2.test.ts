import { expect, assert } from 'chai';
import {
    BStableProxyV2Contract, BStableProxyV2Instance, StableCoinContract, StableCoinInstance, BStablePoolContract,
    BStablePoolInstance,
} from '../build/types/truffle-types';
// Load compiled artifacts
const proxyContract: BStableProxyV2Contract = artifacts.require('BStableProxyV2.sol');
const stableCoinContract: StableCoinContract = artifacts.require('StableCoin.sol');
const poolContract: BStablePoolContract = artifacts.require('BStablePool.sol');
import { BigNumber } from 'bignumber.js';
import { config } from './config';

contract('BStable proxy', async accounts => {


    let proxyInstance: BStableProxyV2Instance;
    let dai: StableCoinInstance;
    let busd: StableCoinInstance;
    let usdt: StableCoinInstance;
    let btcb: StableCoinInstance;
    let renBtc: StableCoinInstance;
    let anyBtc: StableCoinInstance;
    let p1: BStablePoolInstance;
    let p2: BStablePoolInstance;
    let denominator = new BigNumber(10).exponentiatedBy(18);


    before('Get proxy contract instance', async () => {
        proxyInstance = await proxyContract.at(config.proxyAddress);
        let p1Info = await proxyInstance.poolInfo(0);
        let p2Info = await proxyInstance.poolInfo(1);
        p1 = await poolContract.at(p1Info[0]);
        p2 = await poolContract.at(p2Info[0]);
        let coin = await p1.coins(0);
        dai = await stableCoinContract.at(coin);
        coin = await p1.coins(1);
        busd = await stableCoinContract.at(coin);
        coin = await p1.coins(2);
        usdt = await stableCoinContract.at(coin);
        coin = await p2.coins(0);
        btcb = await stableCoinContract.at(coin);
        coin = await p2.coins(1);
        renBtc = await stableCoinContract.at(coin);
        coin = await p2.coins(2);
        anyBtc = await stableCoinContract.at(coin);
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
            console.log('======================================================');
        }

    });


    describe('给地址转账', async () => {

        it('转账', async () => {
            for (let i = 0; i < accounts.length; i++) {
                await dai.transfer(accounts[i], web3.utils.toWei('100000', 'ether'));
                await busd.transfer(accounts[i], web3.utils.toWei('100000', 'ether'));
                await usdt.transfer(accounts[i], web3.utils.toWei('100000', 'ether'));
                await btcb.transfer(accounts[i], web3.utils.toWei('100000', 'ether'));
                await renBtc.transfer(accounts[i], web3.utils.toWei('100000', 'ether'));
                await anyBtc.transfer(accounts[i], web3.utils.toWei('100000', 'ether'));
            }
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
            }
        });

    });

});
