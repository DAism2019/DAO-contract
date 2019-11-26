const WalletHub = artifacts.require("WalletHub");
const WalletTemplateInfos = artifacts.require("WalletTemplateInfos");
const WalletInfos = artifacts.require("WalletInfos");
const WalletTemplateOne = artifacts.require("WalletTemplateOne");

module.exports = function(deployer) {
    deployer.deploy(WalletTemplateInfos);
    deployer.deploy(WalletInfos, WalletHub.address);
    deployer.deploy(WalletTemplateOne);
};
