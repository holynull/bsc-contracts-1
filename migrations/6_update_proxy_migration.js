const BStableProxy = artifacts.require("BStableProxy");
const BStableToken = artifacts.require("BStableToken");

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
        let tokenAddress = "";
        let from = "";
        deployer.then(() => {
            return BStableProxy.new("bStable Pools Proxy for test", "BSPP-V1", tokenAddress);
        }).then(nProxy => {
            let fromContract = BStableProxy.at(from);
            await fromContract.approveLPandTokens(nProxy.address);
            await fromContract.approveLPandTokens();
            await nProxy.migrate(from);
            await nProxy.closeMigration();
        });
    } else {

    }

    // deployer.deploy(factory).then(() => {
    // });
    // deployer.deploy(exchange).then(() => {
    // });
};
