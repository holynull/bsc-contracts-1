const BStablePool = artifacts.require("BStablePool");
const StableCoin = artifacts.require("StableCoin");
const BStableProxyV2 = artifacts.require("BStableProxyV2");
const BStableTokenV2 = artifacts.require("BStableTokenV2");
const config = {
    // owner: '',
    // dev: ''
};

module.exports = async function (deployer, network, accounts) {
    let owner;
    let dev;
    if (config && config.owner) {
        owner = config.owner;
    } else {
        owner = accounts[0];
    }
    if (config && config.dev) {
        dev = config.dev;
    } else {
        dev = accounts[0];
    }
    if (deployer.network.indexOf('skipMigrations') > -1) { // skip migration
        return;
    }
    if (deployer.network.indexOf('_test') > -1) { // skip migration
        return;
    }
    if (deployer.network.indexOf('kovan_oracle') > -1) { // skip migration
        return;
    }
    if (deployer.network_id == 4) { // Rinkeby
    } else if (deployer.network_id == 1) { // main net
    } else if (deployer.network_id == 42) { // kovan
    } else if (deployer.network_id == 56) { // bsc main net
    } else if (deployer.network_id == 5777 || deployer.network_id == 97) { //dev or bsc_test
        let daiAddress;
        let busdAddress;
        let usdtAddress;
        let btcbAddress;
        let renBtcAddress;
        let anyBtcAddress;
        let p1Address;
        let p2Address;
        deployer.then(() => {
            let totalSupply = web3.utils.toWei('100000000', 'ether');
            return StableCoin.new("tDAI for BStable test", "tDAI", totalSupply);
        }).then(dai => {
            daiAddress = dai.address;
            let totalSupply = web3.utils.toWei('100000000', 'ether');
            return StableCoin.new("tUSD for BStable test", "tUSD", totalSupply);
        }).then(busd => {
            busdAddress = busd.address;
            let totalSupply = web3.utils.toWei('100000000', 'ether');
            return StableCoin.new("tUSDT for BStable test", "tUSDT", totalSupply);
        }).then(usdt => {
            usdtAddress = usdt.address;
            let stableCoins = [daiAddress, busdAddress, usdtAddress];
            let A = 200;
            let fee = '10000000';
            let adminFee = '5000000000';
            return BStablePool.new("BStable Pool (tDAI/tUSD/tUSDT) for test", "BSLP-01", stableCoins, A, fee, adminFee, owner);
        }).then(pool => {
            let totalSupply = web3.utils.toWei('100000000', 'ether');
            p1Address = pool.address;
            return StableCoin.new("aBTC for BStable test", "aBTC", totalSupply);
        }).then(btcb => {
            let totalSupply = web3.utils.toWei('100000000', 'ether');
            btcbAddress = btcb.address;
            return StableCoin.new("bBTC for BStable test", "bBTC", totalSupply);
        }).then(renBtc => {
            let totalSupply = web3.utils.toWei('100000000', 'ether');
            renBtcAddress = renBtc.address;
            return StableCoin.new("cBTC for BStable test", "cBTC", totalSupply)
        }).then(anyBtc => {
            anyBtcAddress = anyBtc.address;
            let stableCoins = [btcbAddress, renBtcAddress, anyBtcAddress];
            let A = 200;
            let fee = '10000000';
            let adminFee = '5000000000';
            return BStablePool.new("BStable Pool (aBTC/bBTC/cBTC) for test", "BSLP-02", stableCoins, A, fee, adminFee, owner);
        }).then(async pool => {
            p2Address = pool.address;
            let latestBlock = await web3.eth.getBlock('latest');
            let tokenPerBlock = web3.utils.toWei('1', 'ether');
            let startBlock = latestBlock.number + 10;
            let bonusEndBlock = startBlock + 28800; // one day, 1 block/3 sec
            let proxy = await BStableProxyV2.new(dev, tokenPerBlock, startBlock, bonusEndBlock, owner);
            // await proxy.createWallet();
            let bstAddress = await proxy.getTokenAddress();
            console.log("Token's address: " + bstAddress);
            console.log("Proxy's address: " + proxy.address);
            await proxy.add(6, p1Address, false);
            await proxy.add(4, p2Address, false);
        });
    } else {

    }

};
