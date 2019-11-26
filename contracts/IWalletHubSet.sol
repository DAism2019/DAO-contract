pragma solidity ^0.5.0;

interface IWalletHubSet {
    function setWalletAdminAddress(address new_address) external;
    function setCreateFee(uint newFee) external;
    function setBeneficiary(address payable new_beneficiary) external;
}
