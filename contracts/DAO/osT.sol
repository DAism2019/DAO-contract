pragma solidity ^0.8.0;
pragma abicoder v2;

interface iappInfo{
    function isApp(address appAddress) external view returns(bool);
}

interface iApp{
    function getTo() external view returns(address);
}

contract os{
    
    address immutable appInfo;
    
    constructor(address _appInfo){
        appInfo = _appInfo;
    }
    
    fallback(bytes calldata _in) external payable returns(bytes memory){
        require(iappInfo(appInfo).isApp(msg.sender),"not a app");
        address outDoor = iApp(msg.sender).getTo();
        bool success;
        bytes memory re;
        if(msg.value == 0){
            (success,re) = outDoor.call(_in);
        }
        else{
            (success,re) = outDoor.call{value:msg.value}(_in);
        }
        require(success,"OS/Fallback/call_error");
        emit CallTo(outDoor,_in,block.timestamp);
        return re;
    }
    event CallTo(address indexed outDoor0,bytes _in,uint256);
    receive() external payable{}
}