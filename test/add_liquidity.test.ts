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
const delay = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));
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
    let p1: BStablePoolInstance;
    let p2: BStablePoolInstance;
    let denominator = new BigNumber(10).exponentiatedBy(18);
    let maxApproveAmt = new BigNumber(2).exponentiatedBy(255);


    before('Get proxy contract instance', async () => {
        // proxyInstance = await proxyContract.at('0xD655588Aa65b18566c7a3538835A42a6650dA5B7');
        // let p1Info = await proxyInstance.getPoolInfo(0);
        // let p2Info = await proxyInstance.getPoolInfo(1);
        // p1 = await poolContract.at(p1Info[0]);
        // p2 = await poolContract.at(p2Info[0]);
        // dai = await stableCoinContract.at(p1Info[1][0]);
        // busd = await stableCoinContract.at(p1Info[1][1]);
        // usdt = await stableCoinContract.at(p1Info[1][2]);
        // btcb = await stableCoinContract.at(p2Info[1][0]);
        // renBtc = await stableCoinContract.at(p2Info[1][1]);
        // anyBtc = await stableCoinContract.at(p2Info[1][2]);
        // let tokenAddress = await proxyInstance.getTokenAddress();
        // bst = await tokenContract.at(tokenAddress);

        
    });


    describe('获取用户状态数据', async () => {

        it('获取数据', async () => {
            let sta = new Date().getTime();
            let end = sta + 3600 * 4 * 1000;
            for (; true;) {
                let now = Date.now();
                if (now >= end) {
                    break;
                }
                let rand = Math.floor(Math.random() * 10 * 1000);
                console.log(rand);
                await delay(rand);
            }
        });

    });

});
