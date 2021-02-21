const BStablePool = artifacts.require("BStablePool");
const StableCoin = artifacts.require("StableCoin");
const BStableProxyV2 = artifacts.require("BStableProxyV2");
const BStableTokenV2 = artifacts.require("BStableTokenV2");
const config = require('./config');

module.exports = async function (deployer) {
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
    if (deployer.network.indexOf('kovan_oracle') > -1) { // skip migration
        return;
    }
    if (deployer.network_id == 4) { // Rinkeby
    } else if (deployer.network_id == 1) { // main net
    } else if (deployer.network_id == 42) { // kovan
    } else if (deployer.network_id == 56) { // bsc main net
    } else if (deployer.network_id == 256 || deployer.network_id == 5777) { //heco test net
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
            return StableCoin.new("bowDAI for BStable test", "bstableDAI", totalSupply);
        }).then(dai => {
            daiAddress = dai.address;
            let totalSupply = web3.utils.toWei('100000000', 'ether');
            return StableCoin.new("bstableHUSD for BStable test", "bstableHUSD", totalSupply);
        }).then(busd => {
            busdAddress = busd.address;
            let totalSupply = web3.utils.toWei('100000000', 'ether');
            return StableCoin.new("bstableUSDT for BStable test", "bstableUSDT", totalSupply);
        }).then(usdt => {
            usdtAddress = usdt.address;
            let stableCoins = [daiAddress, busdAddress, usdtAddress];
            let A = 100;
            let fee = 10000000;// 1e-10, 0.003, 0.3%
            // let adminFee = 0;
            let adminFee = 5000000000; // 1e-10, 0.666667, 66.67% 
            return BStablePool.new("BStable Pool (bstableDAI/bstableHUSD/bstableUSDT) for test", "BSLP-01", stableCoins, A, fee, adminFee, owner);
        }).then(pool => {
            let totalSupply = web3.utils.toWei('100000000', 'ether');
            p1Address = pool.address;
            return StableCoin.new("HBTC for BStable test", "HBTC", totalSupply);
        }).then(btcb => {
            let totalSupply = web3.utils.toWei('100000000', 'ether');
            btcbAddress = btcb.address;
            return StableCoin.new("renBTC for BStable test", "renBTC", totalSupply);
        }).then(renBtc => {
            let totalSupply = web3.utils.toWei('100000000', 'ether');
            renBtcAddress = renBtc.address;
            return StableCoin.new("anyBTC for BStable test", "anyBTC", totalSupply)
        }).then(anyBtc => {
            anyBtcAddress = anyBtc.address;
            let stableCoins = [btcbAddress, renBtcAddress, anyBtcAddress];
            let A = 100;
            let fee = 10000000;// 1e-10, 0.003, 0.3%
            // let adminFee = 0;
            let adminFee = 5000000000; // 1e-10, 0.666667, 66.67% 
            return BStablePool.new("BStable Pool (HBTC/renBTC/anyBTC) for test", "BSLP-02", stableCoins, A, fee, adminFee, owner);
        }).then(pool => {
            p2Address = pool.address;
            let proxy = await BStableProxyV2.new(dev, 100, 0, 10, owner);
            // await proxy.createWallet();
            let bstAddress = await proxy.getTokenAddress();
            console.log("Token's address: " + bstAddress);
            console.log("Proxy's address: " + proxy.address);
            await proxy.addPool(6, p1Address, false);
            await proxy.addPool(4, p2Address, false);
        });
    } else {

    }

    // deployer.deploy(factory).then(() => {
    // });
    // deployer.deploy(exchange).then(() => {
    // });
};
