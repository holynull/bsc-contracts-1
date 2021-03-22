import { expect, assert } from 'chai';
import {
    BStableProxyV2DeflationContract,
    BStableProxyV2DeflationInstance,
    BStablePoolContract,
    BStablePoolInstance,
} from '../build/types/truffle-types';
// Load compiled artifacts
const proxyContract: BStableProxyV2DeflationContract = artifacts.require('BStableProxyV2Deflation.sol');
const poolContract: BStablePoolContract = artifacts.require('BStablePool.sol');
const delay = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));
import { BigNumber } from 'bignumber.js';
import { config } from './config'

contract('BStable proxy', async accounts => {


    let proxyInstance: BStableProxyV2DeflationInstance;
    let poolInstance1: BStablePoolInstance;
    let poolInstance2: BStablePoolInstance;

    before('Get proxy contract instance', async () => {
        proxyInstance = await proxyContract.at(config.proxyAddress);
        let poolInfo = await proxyInstance.poolInfo(0);
        poolInstance1 = await poolContract.at(poolInfo[0]);
        poolInfo = await proxyInstance.poolInfo(1);
        poolInstance2 = await poolContract.at(poolInfo[0]);
    });


    describe('测试添加流动性', async () => {

        it('每个账户添加10,000流动性', async () => {
            for (let i = 1; i < accounts.length; i++) {
                let amt = web3.utils.toWei('10000', 'ether');
                await poolInstance1.add_liquidity([amt, amt, amt], 0, { from: accounts[i] });
                await poolInstance2.add_liquidity([amt, amt, amt], 0, { from: accounts[i] });
            }
        });

    });

});
