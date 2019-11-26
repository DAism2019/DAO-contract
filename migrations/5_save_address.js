const fsService = require('../scripts/fileService');
const fileName = "./test/address.json";

const WalletHub = artifacts.require("WalletHub");
const WalletTemplateInfos = artifacts.require("WalletTemplateInfos");
const WalletInfos = artifacts.require("WalletInfos");
const WalletTemplateOne = artifacts.require("WalletTemplateOne");
const WalletAdmin = artifacts.require("WalletAdmin");

const data = {
    "WalletHub": WalletHub.address,
    "WalletTemplateInfos": WalletTemplateInfos.address,
    "WalletInfos": WalletInfos.address,
    "WalletTemplateOne": WalletTemplateOne.address,
    "WalletAdmin": WalletAdmin.address
}

module.exports = function(deployer) {
    fsService.writeJson(fileName, data);
    console.log('address save over');
};
