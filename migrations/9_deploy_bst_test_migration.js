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
        let p1Address = '0x74585D6A59020164b2378dFf664d9391cCd8ceAf';
        let p2Address = '0xA5e91FEd57f256645479eC60D4640D7DCA969ABD';
        deployer.then(() => {
            return BStableTokenForTest.new("bStable DAO Token", "BST");
        }).then(async bst => {
            console.log("Token's address: " + bst.address);
            let proxy = await BStableProxy.new("bStable Pools Proxy for test", "BSPP-V1", bst.address);
            console.log("Proxy's address: " + proxy.address);
            await proxy.addPool(p1Address, ['0x259214B09F546295fBa4A3E258aaE8EB816b6a10', '0x63741B50c84eAF80F583c23A2AD0dB7d73d92AE0', '0xf40F9eaf8c9335A5EF35DaD3206FF028e98E600C'], 6);
            await proxy.addPool(p2Address, ['0xa9505E2308d98c871bfDBe8B339d3a07369f9C99', '0x42427763329B133C209Aa52C5eD2A6D51d2934e1', '0xd7893FfB593437Ef3334eEd34DE4e3F8679E1fDf'], 4);
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
