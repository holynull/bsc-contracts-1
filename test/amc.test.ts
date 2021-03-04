import { expect, assert } from 'chai';
// const chai = require("chai");
// const chaiAsPromised = require("chai-as-promised");

// chai.use(chaiAsPromised);

// // Then either:
// const expect = chai.expect;
// // or:
// const assert = chai.assert;

import {
    BStableTokenV2Contract,
    AssetManagementCenterContract,
    AssetManagementCenterInstance,
    BStableTokenV2Instance,
    InvestorPassbookContract,
    InvestorPassbookInstance
} from '../build/types/truffle-types';
// Load compiled artifacts
const tokenContract: BStableTokenV2Contract = artifacts.require('BStableTokenV2.sol');
const amcContract: AssetManagementCenterContract = artifacts.require('AssetManagementCenter.sol');
const passbookContract: InvestorPassbookContract = artifacts.require('InvestorPassbook.sol');
const delay = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));
import { BigNumber } from 'bignumber.js';

contract('Asset Management Center', async accounts => {

    let coinInstance: BStableTokenV2Instance;
    let amcInstance: AssetManagementCenterInstance;
    let passbooks: InvestorPassbookInstance[];

    let denominator = new BigNumber(10).exponentiatedBy(18);

    before('Get proxy contract instance', async () => {
        coinInstance = await tokenContract.deployed();
        amcInstance = await amcContract.deployed();
        amcInstance.setTokenAddress(coinInstance.address);
    });


    describe('AssetManagementCenter', () => {

        it('addInvestorInfo', async () => {
            let now = Math.floor(new Date().getTime() / 1000);
            let staTime = now;
            let endTime = now + (60 * 5);
            await amcInstance.addInvestorInfo(accounts[1], 3, staTime, endTime);
            await amcInstance.addInvestorInfo(accounts[2], 2, staTime, endTime);
            await amcInstance.addInvestorInfo(accounts[3], 1, staTime, endTime);
        }).timeout(84600 * 1000);;

        it('Query data', async () => {
            let totalWeight = await amcInstance.totalWeight();
            console.log("totalWeight: " + totalWeight.toNumber());
            let res = await amcInstance.infos(accounts[1]);
            console.log("account 1's weight: " + res[1].toNumber());
            console.log("account 1's staTime: " + new Date(res[3].toNumber() * 1000));
            console.log("account 1's endTime: " + new Date(res[4].toNumber() * 1000));
            res = await amcInstance.infos(accounts[2]);
            console.log("account 2's weight: " + res[1].toNumber());
            console.log("account 2's staTime: " + new Date(res[3].toNumber() * 1000));
            console.log("account 2's endTime: " + new Date(res[4].toNumber() * 1000));
            res = await amcInstance.infos(accounts[3]);
            console.log("account 3's weight: " + res[1].toNumber());
            console.log("account 3's staTime: " + new Date(res[3].toNumber() * 1000));
            console.log("account 3's endTime: " + new Date(res[4].toNumber() * 1000));
            let balanceStr = await coinInstance.balanceOf(amcInstance.address);
            console.log("amc balance: " + new BigNumber(balanceStr).div(denominator).toFormat(18, 1));
        });
        it('setInvestorInfo', async () => {
            let now = Math.floor(new Date().getTime() / 1000);
            let staTime = now;
            let endTime = now + (60 * 5);
            await amcInstance.setInvestorInfo(accounts[1], 4, staTime, endTime);
            await amcInstance.setInvestorInfo(accounts[2], 5, staTime, endTime);
            await amcInstance.setInvestorInfo(accounts[3], 6, staTime, endTime);
            try {
                await amcInstance.setInvestorInfo(accounts[4], 7, staTime, endTime);
            } catch (e) {
                console.log(e.reason);
            }
        }).timeout(84600 * 1000);;
        it('Query data', async () => {
            let totalWeight = await amcInstance.totalWeight();
            console.log("totalWeight: " + totalWeight.toNumber());
            let res = await amcInstance.infos(accounts[1]);
            console.log("account 1's weight: " + res[1].toNumber());
            console.log("account 1's staTime: " + new Date(res[3].toNumber() * 1000));
            console.log("account 1's endTime: " + new Date(res[4].toNumber() * 1000));
            res = await amcInstance.infos(accounts[2]);
            console.log("account 2's weight: " + res[1].toNumber());
            console.log("account 2's staTime: " + new Date(res[3].toNumber() * 1000));
            console.log("account 2's endTime: " + new Date(res[4].toNumber() * 1000));
            res = await amcInstance.infos(accounts[3]);
            console.log("account 3's weight: " + res[1].toNumber());
            console.log("account 3's staTime: " + new Date(res[3].toNumber() * 1000));
            console.log("account 3's endTime: " + new Date(res[4].toNumber() * 1000));
        });
        it('setInvestorInfo', async () => {
            let now = Math.floor(new Date().getTime() / 1000);
            let staTime = now;
            let endTime = now + (60 * 5);
            await amcInstance.setInvestorInfo(accounts[1], 4, staTime, endTime);
            await amcInstance.setInvestorInfo(accounts[2], 5, staTime, endTime);
            await amcInstance.setInvestorInfo(accounts[3], 6, staTime, endTime);
            try {
                await amcInstance.setInvestorInfo(accounts[4], 7, staTime, endTime);
            } catch (e) {
                console.log(e.reason);
            }
        }).timeout(84600 * 1000);;
        it('distributeAsset', async () => {
            let now = Math.floor(new Date().getTime() / 1000);
            let staTime = now;
            let endTime = now + (60 * 5);
            await amcInstance.distributeAsset();
            try {
                await amcInstance.distributeAsset();
            } catch (e) {
                console.log(e.reason);
            }
            try {
                await amcInstance.addInvestorInfo(accounts[4], 7, staTime, endTime);
            } catch (e) {
                console.log(e.reason);
            }
            try {
                await amcInstance.setInvestorInfo(accounts[4], 7, staTime, endTime);
            } catch (e) {
                console.log(e.reason);
            }
        }).timeout(84600 * 1000);;
        it('Query data', async () => {
            let balanceStr = await coinInstance.balanceOf(amcInstance.address);
            console.log("amc balance: " + new BigNumber(balanceStr).div(denominator).toFormat(18, 1));
            passbooks = new Array();
            let res = await amcInstance.infos(accounts[1]);
            let pbInstance: InvestorPassbookInstance = await passbookContract.at(res[2]);
            passbooks.push(pbInstance);
            let pbBalStr = await coinInstance.balanceOf(pbInstance.address);
            console.log("passbook 1 balance: " + new BigNumber(pbBalStr).div(denominator).toFormat(18, 1));
            res = await amcInstance.infos(accounts[2]);
            pbInstance = await passbookContract.at(res[2]);
            passbooks.push(pbInstance);
            pbBalStr = await coinInstance.balanceOf(pbInstance.address);
            console.log("passbook 2 balance: " + new BigNumber(pbBalStr).div(denominator).toFormat(18, 1));
            res = await amcInstance.infos(accounts[3]);
            pbInstance = await passbookContract.at(res[2]);
            passbooks.push(pbInstance);
            pbBalStr = await coinInstance.balanceOf(pbInstance.address);
            console.log("passbook 3 balance: " + new BigNumber(pbBalStr).div(denominator).toFormat(18, 1));
        }).timeout(84600 * 1000);;
        it('claim', async () => {
            let sta = new Date().getTime();
            let end = sta + 60 * 6 * 1000;
            for (; true;) {
                let now = Date.now();
                if (now >= end) {
                    break;
                }
                let delayMS = Math.floor(Math.random() * 10 * 1000);
                await delay(delayMS);
                for (let i = 0; i < passbooks.length; i++) {
                    await passbooks[i].claim({ from: accounts[i + 1] });
                }
                let balanceStr = await coinInstance.balanceOf(amcInstance.address);
                console.log("amc balance: " + new BigNumber(balanceStr).div(denominator).toFormat(18, 1));
                passbooks = new Array();
                let res = await amcInstance.infos(accounts[1]);
                let pbInstance: InvestorPassbookInstance = await passbookContract.at(res[2]);
                passbooks.push(pbInstance);
                let pbBalStr = await coinInstance.balanceOf(pbInstance.address);
                console.log("passbook 1 balance: " + new BigNumber(pbBalStr).div(denominator).toFormat(18, 1));
                res = await amcInstance.infos(accounts[2]);
                pbInstance = await passbookContract.at(res[2]);
                passbooks.push(pbInstance);
                pbBalStr = await coinInstance.balanceOf(pbInstance.address);
                console.log("passbook 2 balance: " + new BigNumber(pbBalStr).div(denominator).toFormat(18, 1));
                res = await amcInstance.infos(accounts[3]);
                pbInstance = await passbookContract.at(res[2]);
                passbooks.push(pbInstance);
                pbBalStr = await coinInstance.balanceOf(pbInstance.address);
                console.log("passbook 3 balance: " + new BigNumber(pbBalStr).div(denominator).toFormat(18, 1));
            }
        }).timeout(84600 * 1000);;
        it('Query data', async () => {
            let balanceStr = await coinInstance.balanceOf(amcInstance.address);
            console.log("amc balance: " + new BigNumber(balanceStr).div(denominator).toFormat(18, 1));
            passbooks = new Array();
            let res = await amcInstance.infos(accounts[1]);
            let pbInstance: InvestorPassbookInstance = await passbookContract.at(res[2]);
            passbooks.push(pbInstance);
            let pbBalStr = await coinInstance.balanceOf(pbInstance.address);
            console.log("passbook 1 balance: " + new BigNumber(pbBalStr).div(denominator).toFormat(18, 1));
            res = await amcInstance.infos(accounts[2]);
            pbInstance = await passbookContract.at(res[2]);
            passbooks.push(pbInstance);
            pbBalStr = await coinInstance.balanceOf(pbInstance.address);
            console.log("passbook 2 balance: " + new BigNumber(pbBalStr).div(denominator).toFormat(18, 1));
            res = await amcInstance.infos(accounts[3]);
            pbInstance = await passbookContract.at(res[2]);
            passbooks.push(pbInstance);
            pbBalStr = await coinInstance.balanceOf(pbInstance.address);
            console.log("passbook 3 balance: " + new BigNumber(pbBalStr).div(denominator).toFormat(18, 1));
        }).timeout(84600 * 1000);;
    });

});
