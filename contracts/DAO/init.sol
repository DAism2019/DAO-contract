pragma solidity ^0.8.0;
pragma abicoder v2;

interface iGlobal{
    function daoToAppInfo(uint32) external returns(address);
    function osDao(address) external returns(uint32);
    function daoVote(uint32) external returns(address);
    function daoDatabase(uint32) external returns(address);
}

interface iVote{
    function addMap(address _appAddress,uint32 voteNumberExternal,uint32 voteNumberInternal) external;
}

interface iDatabase{
    function addMap(address _appAddress,uint32 databaseExternal,uint32 databaseInternal) external;
}
contract init{
    address immutable register;
    address immutable global;
    
    constructor(address _register,address _global){
        //appInfo = _appInfo;
        register = _register;
        global = _global;
    }
    
    function initAppsByRegiste(address[] memory apps,bytes[] memory _calldata,bytes[] memory _message,uint32 _daoNumber) external {
        require(msg.sender == register,"Error :not register");
        _initApps(apps,_calldata,_message,_daoNumber);
    }
    
    function _initApps(address[] memory apps,bytes[] memory _calldata,bytes[] memory _message,uint32 _daoNumber) internal {
        for(uint256 i = 0;i < apps.length;i++){
            apps[i].call(_calldata[i]);
            (uint32 vote1,uint32 vote2,uint32 database1,uint32 database2) = abi.decode(_message[i],(uint32,uint32,uint32,uint32));
            address voteAddress = iGlobal(global).daoVote(_daoNumber);
            address databaseAddress = iGlobal(global).daoDatabase(_daoNumber);
            iVote(voteAddress).addMap(apps[i],vote1,vote2);
            iDatabase(databaseAddress).addMap(apps[i],database1,database2);
        }
    }
    
    function initApps(address[] memory apps,bytes[] memory _calldata,bytes[] memory _message) external {
        uint32 daoNumber = iGlobal(global).osDao(msg.sender);
        require(daoNumber != 0,"Error not a dao");
        _initApps(apps,_calldata,_message,daoNumber);
    }
}