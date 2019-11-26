const WalletHub = artifacts.require("WalletHub");
const WalletAdmin = artifacts.require("WalletAdmin");
const WalletTemplateInfos = artifacts.require("WalletTemplateInfos");
const WalletTemplateOne = artifacts.require("WalletTemplateOne");
const {constants} = require('ethers')

contract("WalletHub", async accounts => {
    it("setup_correctly", async () => {
        let instance = await WalletHub.deployed();
        await instance.setBeneficiary(accounts[1],{from:accounts[0]});
        let beneficiary = await instance.getBeneficiary();
        assert.equal(beneficiary, accounts[1], "beneficiary wasn't accounts[1]")
        await instance.setWalletAdminAddress(WalletAdmin.address);
        let wallet_admin_address = await instance.getWalletAdminAddress();
        assert.equal(wallet_admin_address,WalletAdmin.address,"wallet_admin_address is incorrect");
        assert.notEqual(wallet_admin_address,constants.AddressZero,"wallet_admin_address is zero_address")
    });
});

contract("WalletTemplateInfos",async accounts =>{
    it("add_template_correctly",async ()=>{
        let instance = await WalletTemplateInfos.deployed();
        await instance.addTemplate(WalletTemplateOne.address);
        let template = await instance.allTemplates(0)
        assert.notEqual(template,constants.AddressZero,"template at index_0 is zero_address");
        assert.equal(template,WalletTemplateOne.address,"template at index_0 is incorrect");
    });
});
