pragma solidity ^0.8.0;
pragma abicoder v2;

interface iOs{
    function getAddress(uint32,uint8) external returns(address);
}

contract Delegate{
    address immutable public os;
    uint32 immutable public appIndex;
    uint8 immutable public constituteIndex;

    constructor(address _os,uint32 _appIndex,uint8 _constituteIndex){
        os = _os;
        appIndex = _appIndex;
        constituteIndex = _constituteIndex;
    }

    fallback(bytes calldata _in) external payable returns(bytes memory out){
        address callTo = iOs(os).getAddress(appIndex,constituteIndex);
        (bool success,bytes memory re) = callTo.delegatecall(_in);
        require( success ,"Delegate/fallback/delegatecall/not_success");
        out = re;
    }

    receive() external payable{}
}