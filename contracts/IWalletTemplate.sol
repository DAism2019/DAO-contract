pragma solidity ^0.5.0;
interface IWalletTemplate {
    function initWallet(address[] calldata _owners, uint _required) external;
}
