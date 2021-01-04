import { expect, assert } from 'chai';
import {
    BStableProxyContract,
    BStableProxyInstance,
    BStableTokenForTestDEVContract,
    BStableTokenForTestDEVInstance,
} from '../build/types/truffle-types';
// Load compiled artifacts
const proxyContract: BStableProxyContract = artifacts.require('BStableProxy.sol');
const tokenContract: BStableTokenForTestDEVContract = artifacts.require('BStableTokenForTestDEV.sol');
import { BigNumber } from 'bignumber.js';
import { config } from './config';

contract('BStable proxy', async accounts => {


    let proxyInstance: BStableProxyInstance;
    let bst: BStableTokenForTestDEVInstance;
    let denominator = new BigNumber(10).exponentiatedBy(18);


    before('Get proxy contract instance', async () => {
        proxyInstance = await proxyContract.at(config.proxyAddress);
        let tokenAddress = await proxyInstance.getTokenAddress();
        bst = await tokenContract.at(tokenAddress);
    });


    describe('测试token合约', async () => {

        it('测试updateMiningParameter', async () => {
            await bst.updateMiningParameters();
            console.log('======================================================');
            let bstTotalSupply = await bst.totalSupply();
            console.log('BST totalSupply: ' + new BigNumber(bstTotalSupply).div(denominator).toFormat(18, BigNumber.ROUND_DOWN));
            let bstAvailableSupply = await bst.availableSupply();
            console.log('BST availableSupply: ' + new BigNumber(bstAvailableSupply).div(denominator).toFormat(18, BigNumber.ROUND_DOWN));
            console.log('======================================================');
        });

    });

});
