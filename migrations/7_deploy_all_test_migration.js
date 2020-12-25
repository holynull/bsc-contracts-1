const BStablePool = artifacts.require("BStablePool");
const StableCoin = artifacts.require("StableCoin");
const BStableProxy = artifacts.require("BStableProxy");
const BStableTokenForTest = artifacts.require("BStableTokenForTest");

module.exports = async function (deployer) {
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
    } else if (deployer.network_id == 97 || deployer.network_id == 5777) { //bsc test net
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
            return StableCoin.new("DAI for bStable test", "bstDAI", totalSupply);
        }).then(dai => {
            daiAddress = dai.address;
            let totalSupply = web3.utils.toWei('100000000', 'ether');
            return StableCoin.new("BUSD for bStable test", "bstBUSD", totalSupply);
        }).then(busd => {
            busdAddress = busd.address;
            let totalSupply = web3.utils.toWei('100000000', 'ether');
            return StableCoin.new("USDT for bStable test", "bstUSDT", totalSupply);
        }).then(usdt => {
            usdtAddress = usdt.address;
            let stableCoins = [daiAddress, busdAddress, usdtAddress];
            let A = 100;
            let fee = 30000000;// 1e-10, 0.003, 0.3%
            // let adminFee = 0;
            let adminFee = 6666666666; // 1e-10, 0.666667, 66.67% 
            return BStablePool.new("bstable Pool (bstDAI/bstBUSD/bstUSDT) for test", "BSLP-01", stableCoins, A, fee, adminFee);
        }).then(pool => {
            let totalSupply = web3.utils.toWei('100000000', 'ether');
            p1Address = pool.address;
            return StableCoin.new("BTCB for bStable test", "BTCB", totalSupply);
        }).then(btcb => {
            let totalSupply = web3.utils.toWei('100000000', 'ether');
            btcbAddress = btcb.address;
            return StableCoin.new("renBTC for bStable test", "renBTC", totalSupply);
        }).then(renBtc => {
            let totalSupply = web3.utils.toWei('100000000', 'ether');
            renBtcAddress = renBtc.address;
            return StableCoin.new("anyBTC for bStable test", "anyBTC", totalSupply)
        }).then(anyBtc => {
            anyBtcAddress = anyBtc.address;
            let stableCoins = [btcbAddress, renBtcAddress, anyBtcAddress];
            let A = 100;
            let fee = 30000000;// 1e-10, 0.003, 0.3%
            // let adminFee = 0;
            let adminFee = 6666666666; // 1e-10, 0.666667, 66.67% 
            return BStablePool.new("bstable Pool (BTCB/renBTC/anyBTC) for test", "BSLP-02", stableCoins, A, fee, adminFee);
        }).then(pool => {
            p2Address = pool.address;
            return BStableTokenForTest.new("bStable DAO Token", "BST");
        }).then(async bst => {
            console.log("Token's address: " + bst.address);
            let proxy = await BStableProxy.new("bStable Pools Proxy for test", "BSPP-V1", bst.address);
            console.log("Proxy's address: " + proxy.address);
            await proxy.addPool(p1Address, [daiAddress, busdAddress, usdtAddress], 6);
            await proxy.addPool(p2Address, [btcbAddress, renBtcAddress, anyBtcAddress], 4);
            await bst.setMinter(proxy.address);
            await bst.updateMiningParameters();
        });
    } else {

    }

    // deployer.deploy(factory).then(() => {
    // });
    // deployer.deploy(exchange).then(() => {
    // });
};
