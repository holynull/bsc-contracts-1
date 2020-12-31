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

contract('BStable proxy', async accounts => {


    let proxyInstance: BStableProxyInstance;
    let bst: BStableTokenForTestDEVInstance;
    let denominator = new BigNumber(10).exponentiatedBy(18);


    before('Get proxy contract instance', async () => {
        proxyInstance = await proxyContract.at('0xD655588Aa65b18566c7a3538835A42a6650dA5B7');
        let tokenAddress = await proxyInstance.getTokenAddress();
        bst = await tokenContract.at(tokenAddress);
        await bst.updateMiningParameters();
        console.log('======================================================');
        let bstTotalSupply = await bst.totalSupply();
        console.log('BST totalSupply: ' + new BigNumber(bstTotalSupply).div(denominator).toFormat(18, BigNumber.ROUND_DOWN));
        let bstAvailableSupply = await bst.availableSupply();
        console.log('BST availableSupply: ' + new BigNumber(bstAvailableSupply).div(denominator).toFormat(18, BigNumber.ROUND_DOWN));
        console.log('======================================================');
    });


    describe('获取用户状态数据', async () => {

        it('获取数据', async () => {

        });

    });

});
