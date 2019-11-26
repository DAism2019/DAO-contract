pragma solidity ^0.5.0;

interface IWalletHubGet {
    function getWalletAdminAddress() external view returns(address);
    function getCreateFee() external view returns(uint);
    function getBeneficiary() external view returns(address payable);
}
