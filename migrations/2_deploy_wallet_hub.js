const WalletHub = artifacts.require("WalletHub");

module.exports = function(deployer) {
    deployer.deploy(WalletHub,{overwrite:false});
};
