pragma solidity ^0.5.0;
import "./IWalletTemplate.sol";
import "./CloneFactory.sol";
import "./IWalletHubGet.sol";

contract WalletTemplateInfosInterface {
    function allTemplates(uint index) external view returns(address);
    function getTemplateCount() external view returns(uint);
    function isFrozen(address _template) external view returns(bool);
}

contract WalletInfosInterface {
    function saveWalletInfo(address creator,address wallet,string calldata name,uint templateIndex) external returns(uint);
}


// this contract can be upgraded to use multi wallet_template
contract WalletAdmin is CloneFactory {
    WalletTemplateInfosInterface public templates;          //instance of WalletTemplateInfos
    WalletInfosInterface public wallet_infos;               //instance of WalletInfos
    IWalletHubGet public wallet_hub;                        //instance of wallet_hub

    event createWalletSuc(address indexed creator,address wallet,string name,uint templateIndex,uint amount);


    constructor(address wallet_hub_address,address templateInfos_address,address wallet_infos_address) public {
        /**
            @param templateInfos_address The address of template_infos
            @param wallet_infos_address The address of wallet_infos
            @param wallet_hub_address The address of wallet_hub
        */
        require(wallet_hub_address != address(0),"WalletAdmin: zero_address");
        require(templateInfos_address != address(0) && wallet_infos_address != address(0),"WalletAdmin: zero_address");
        templates = WalletTemplateInfosInterface(templateInfos_address);
        wallet_infos = WalletInfosInterface(wallet_infos_address);
        wallet_hub = IWalletHubGet(wallet_hub_address);
    }

    //return the fee of creating wallet
    function getCreateFee() external view returns(uint) {
        return wallet_hub.getCreateFee();
    }

    function createWallet(string calldata name,address[] calldata _owners, uint _required,uint templateIndex) payable external {
        /**
            @dev Create a MultiSigWallet
            @param name The name of wallet
            @param _owners Initial owners
            @param _required Initial required
            @param templateIndex The index of wallet_template to be cloned
        */
        _check_pay(msg.value);
        //create wallet and init
        address wallet = createClone(_check_template(templateIndex));
        IWalletTemplate(wallet).initWallet(_owners,_required);
        //save wallet info
        uint amount = wallet_infos.saveWalletInfo(msg.sender,wallet,name,templateIndex);
        emit createWalletSuc(msg.sender,wallet,name,templateIndex,amount);
    }

    function _check_pay(uint eth_value) private {
        uint fee = wallet_hub.getCreateFee();
        require(eth_value >= fee,'WalletAdmin: insufficient ethers');
        address payable beneficiary = wallet_hub.getBeneficiary();
        if(fee > 0){
            require(beneficiary != address(0),"WalletAdmin: transfer ethers to zero_address");
            beneficiary.transfer(eth_value);
        }
    }

    function _check_template(uint templateIndex) private view returns(address) {
        uint count = templates.getTemplateCount();
        require(templateIndex < count,"WalletAdmin: templateIndex out of bounds");
        address _template = templates.allTemplates(templateIndex);
        require(!templates.isFrozen(_template),"WalletAdmin: template has been frozen");
        return _template;
    }
}
