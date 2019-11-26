pragma solidity ^0.5.0;
import "./Ownable.sol";
import "./IWalletHubGet.sol";
import "./IWalletHubSet.sol";

contract WalletHub is Ownable,IWalletHubGet,IWalletHubSet {
    IWalletHubGet public instance;                      //a new instance of self
    bool public isUpgrade;                          // has been upgraded
    address private wallet_admin_address;           //address of wallet_admin contract
    address payable private _beneficiary;                   //address of beneficiary
    uint private _createFee;                        // the fee of creating wallet

    event setCreateFeeSuc(uint newFee);
    event upgradeSuc(address to);
    event setWalletAdminAddressSuc(address old_address ,address new_address);
    event setBeneficiarySuc(address old_address ,address new_address);

    modifier noZeroAddress(address _addrss) {
        require(_addrss != address(0),"WalletHub: zero_address");
        _;
    }

    function upgrade(address new_address) noZeroAddress(new_address) external onlyOwner {
        /**
            @dev Upgrade this contract
            @param new_address The address of new contract
        */
        isUpgrade = true;
        instance = IWalletHubGet(new_address);
    }


    function getCreateFee() external view returns(uint) {
        /**
            @return The fee of creating wallet
        */
        if(isUpgrade){
            return instance.getCreateFee();
        }else{
            return _createFee;
        }
    }

    function setCreateFee(uint newFee) external onlyOwner {
        /**
            @dev Set the fee of creating wallet
            @param newFee The new fee of creating wallet
        */
        _createFee = newFee;
        emit setCreateFeeSuc(newFee);
    }

    function getBeneficiary() external view returns(address payable) {
        /**
            @return The getBeneficiary
        */
        if(isUpgrade){
            return instance.getBeneficiary();
        }else{
            return _beneficiary;
        }
    }

    function setBeneficiary(address payable new_beneficiary) external noZeroAddress(new_beneficiary) onlyOwner {
        /**
            @dev Set the new  beneficiary
            @param new_beneficiary The address of new beneficiary
        */
        emit setBeneficiarySuc(_beneficiary,new_beneficiary);
        _beneficiary = new_beneficiary;


    }

    function getWalletAdminAddress() external view returns(address) {
        /**
            @return The address of wallet_admin contract
        */
        if(isUpgrade) {
            return instance.getWalletAdminAddress();
        }else{
            return wallet_admin_address;
        }

    }

    function setWalletAdminAddress(address new_address) noZeroAddress(new_address) external onlyOwner {
        /**
            @dev Set the address of wallet_admin contract
            @param new_address The address of wallet_admin contract
        */
        emit setWalletAdminAddressSuc(wallet_admin_address,new_address);
        wallet_admin_address = new_address;
    }
}
