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
const delay = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));
import { BigNumber } from 'bignumber.js';
import { config } from './config';

contract('BStable proxy', async accounts => {


    let proxyInstance: BStableProxyV2Instance;
    let pools = Array<BStablePoolInstance>();
    let denominator = new BigNumber(10).exponentiatedBy(18);

    before('Get proxy contract instance', async () => {
        proxyInstance = await proxyContract.at(config.proxyAddress);
        let p1Info = await proxyInstance.poolInfo(0);
        let p2Info = await proxyInstance.poolInfo(1);
        let p1 = await poolContract.at(p1Info[0]);
        let p2 = await poolContract.at(p2Info[0]);
        pools.push(p1);
        pools.push(p2);
    });


    describe('测试紧急提取LP', async () => {

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
                if (randUserId === 0) {
                    continue;
                }
                let poolIndex = Math.floor(Math.random() * 2);
                let account = accounts[randUserId];
                await proxyInstance.emergencyWithdraw(poolIndex, { from: account }).catch(e => {
                    console.log(e);
                });
                console.log('accounts[' + account + '] emergency withdraw LP from P' + (poolIndex + 1));
            }
        }).timeout(84600 * 1000);
    });

});
