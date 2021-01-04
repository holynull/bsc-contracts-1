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
import { config } from './config';

contract('BStable proxy', async accounts => {


    let proxyInstance: BStableProxyInstance;
    let pools = Array<BStablePoolInstance>();
    let denominator = new BigNumber(10).exponentiatedBy(18);

    before('Get proxy contract instance', async () => {
        proxyInstance = await proxyContract.at(config.proxyAddress);
        let p1Info = await proxyInstance.getPoolInfo(0);
        let p2Info = await proxyInstance.getPoolInfo(1);
        let p1 = await poolContract.at(p1Info[0]);
        let p2 = await poolContract.at(p2Info[0]);
        pools.push(p1);
        pools.push(p2);
    });


    describe('测试提取LP', async () => {

        it('每个用户随机锁定LP', async () => {
            let sta = new Date().getTime();
            let end = sta + 3600 * 4 * 1000;
            for (; true;) {
                let now = Date.now();
                if (now >= end) {
                    break;
                }
                let delayMS = Math.floor(Math.random() * 10 * 1000);
                await delay(delayMS);
                let randUserId = Math.floor(Math.random() * 10);
                let poolIndex = Math.floor(Math.random() * 2);
                let account = accounts[randUserId];
                let userInfo = await proxyInstance.getUserInfo(poolIndex, account);
                let lpBalStr = userInfo[0];
                let randPercent = Math.floor(Math.random() * 100);
                let amt = new BigNumber(lpBalStr).multipliedBy(randPercent).div(100).toFixed(0, BigNumber.ROUND_DOWN);
                await proxyInstance.withdraw(poolIndex, amt, { from: account }).catch(e => {
                    console.log(e);
                });
                console.log('accounts[' + account + '] withdraw LP from P' + (poolIndex + 1) + ': ' + new BigNumber(amt).div(denominator).toFormat(18, BigNumber.ROUND_DOWN));
            }
        }).timeout(84600 * 1000);
    });

});
