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
import { config } from './config'

contract('BStable proxy', async accounts => {


    let proxyInstance: BStableProxyInstance;
    let poolInstance1: BStablePoolInstance;
    let poolInstance2: BStablePoolInstance;

    before('Get proxy contract instance', async () => {
        proxyInstance = await proxyContract.at(config.proxyAddress);
        let poolAddress = await proxyInstance.getPoolAddress(0);
        poolInstance1 = await poolContract.at(poolAddress);
        poolAddress = await proxyInstance.getPoolAddress(1);
        poolInstance2 = await poolContract.at(poolAddress);
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
