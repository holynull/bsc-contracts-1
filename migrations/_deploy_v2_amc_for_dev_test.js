const AssetManagementCenter = artifacts.require("AssetManagementCenter");
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
        await deployer.deploy(AssetManagementCenter, accounts[0]);
        await deployer.deploy(BStableTokenV2, accounts[0], accounts[0], AssetManagementCenter.address);
    } else {

    }

};
