const WalletAdmin = artifacts.require("WalletAdmin");
const WalletHub = artifacts.require("WalletHub");
const WalletTemplateInfos = artifacts.require("WalletTemplateInfos");
const WalletInfos = artifacts.require("WalletInfos");

module.exports = function(deployer) {
    deployer.deploy(WalletAdmin, WalletHub.address,WalletTemplateInfos.address, WalletInfos.address);
};
