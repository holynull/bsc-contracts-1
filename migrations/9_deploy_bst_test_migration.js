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
        let from = '0xFc50cC3eC8631c3BD61B834Fd8EfA4BA2B11A035';
        deployer.then(() => {
            return BStableTokenForTest.new("bStable DAO Token", "BST");
        }).then(async bst => {
            console.log("Token's address: " + bst.address);
            let proxy = await BStableProxy.new("bStable Pools Proxy for test", "BSPP-V1", bst.address);
            console.log("Proxy's address: " + proxy.address);
            let pfrom = await BStableProxy.at(from);
            let pool1 = await pfrom.getPoolInfo(0);
            let pool2 = await pfrom.getPoolInfo(1);
            await proxy.addPool(pool1._poolAddress, pool1._coins, 6);
            await proxy.addPool(pool2._poolAddress, pool2._coins, 4);
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
