pragma solidity ^0.8.0;
pragma abicoder v2;
import "./DELEGATE.sol";

interface iAppStore{
    function install(uint64 appNumber,uint32 _version,address) external view returns(bytes memory installData);
    function update(uint64 appNumber,uint32 _version,address) external view returns(bytes memory updateData);
    function replace(uint64 appNumber1,uint32 _version1,uint64 appNumber2,uint32 _version2,address) external view returns(bytes memory replaceData);
}

interface iappInfo{
    function install(uint64 _number,bytes memory appData)external;
    function isApp(address appAddress) external view returns(bool);
    function uninstall(uint64 _appNumber) external;
    function recover(uint64 _appNumber) external;
    function update(uint32 _appnumber,bytes memory updateData) external;
    function replace(uint32 _appnumber,bytes memory replaceData) external;
    function getAppNext() external returns(uint32);
    function getVersion(uint32 _appnumber) external view returns(uint32,uint64);
}

interface iGlobal{
    function daoToAppInfo(uint32) external returns(address);
    function osDao(address) external returns(uint32);
}

contract Install{
    //address mutable appInfo;
    address immutable register;
    address immutable global;
    address immutable appStore;
    constructor(address _register,address _global,address _appStore){
        //appInfo = _appInfo;
        register = _register;
        global = _global;
        appStore = _appStore;
    }
    
    function install(uint64 _number,uint32 _version) external returns(address[] memory) {
        //address appInfo = iGlobal(global).daoToAppInfo(_daoNumber);
        //bool isAppT = iappInfo(appInfo).isApp(msg.sender);
        uint32 number = iGlobal(global).osDao(msg.sender);
        require(number != 0 ,"Error:Install error");
        address appInfo = iGlobal(global).daoToAppInfo(number);
        return _install(_number,appInfo,_version);
    }
    
    function installByRegiste(uint64 _number,uint32 daoNumber,uint32 _version) external returns(address[] memory) {
        require(msg.sender == register,"Error:Install error");
        address appInfo = iGlobal(global).daoToAppInfo(daoNumber);
        require(appInfo != address(0));
        return _install(_number,appInfo,_version);
    }
    
    function _install(uint64 _number,address _appInfo,uint32 _version) internal returns(address[] memory){
        bytes memory data = iAppStore(appStore).install(_number,_version,_appInfo);
        (string memory _name,address[] memory con,uint8[] memory _type) = abi.decode(data,(string,address[],uint8[]));
        address[] memory delegates = new address[](con.length);
        uint16[] memory numbers = new uint16[](_type.length);
        uint32 appNext = iappInfo(_appInfo).getAppNext();
        for(uint256 i = 0;i < con.length;i++){
            Delegate dele = new Delegate(_appInfo,appNext,uint8(i));
            delegates[i] = address(dele);
            numbers[i] = uint16(_type[i]) << 8 + uint16(i);
        }
        bytes memory installData = abi.encode(_name,con,delegates,numbers,_version);
        iappInfo(_appInfo).install(_number,installData);
        return delegates;
    }
    
    function uninstall(uint32 _number) external {
        uint32 number = iGlobal(global).osDao(msg.sender);
        require(number != 0 ,"Error:Install error");
        address appInfo = iGlobal(global).daoToAppInfo(number);
        iappInfo(appInfo).uninstall(_number);
    }
    
    function recover(uint32 _number) external {
        uint32 number = iGlobal(global).osDao(msg.sender);
        require(number != 0 ,"Error:Install error");
        address appInfo = iGlobal(global).daoToAppInfo(number);
        iappInfo(appInfo).recover(_number);
    }
    
    function update(uint32 _number) external{
        uint32 number = iGlobal(global).osDao(msg.sender);
        require(number != 0 ,"Error:Install error");
        address appInfo = iGlobal(global).daoToAppInfo(number);
        (uint32 _ver,uint64 _index) = iappInfo(appInfo).getVersion(_number);
        bytes memory updateData = iAppStore(appStore).update(_index,_ver,appInfo);
        (string memory _name,address[] memory con,uint8[] memory _type,uint8 addLen,uint32 _version) = abi.decode(updateData,(string,address[],uint8[],uint8,uint32));
        address[] memory delegates = new address[](addLen);
        uint16[] memory numberSum = new uint16[](_type.length);
        for(uint256 i = 0;i < con.length;i++){
            if(i >= con.length-addLen){
                Delegate dele = new Delegate(appInfo,_number,uint8(i));
                delegates[i - con.length + addLen] = address(dele);
            }
            numberSum[i] = uint16(_type[i]) << 8 + uint16(i);
            
        }
        bytes memory updateDataTo = abi.encode(_name,con,delegates,numberSum,_version);
        iappInfo(appInfo).update(_number,updateDataTo);
    }
    
    function repalce(uint32 _number,uint64 _appIndex,uint32 _version) external{
        uint32 number = iGlobal(global).osDao(msg.sender);
        require(number != 0, "Error:Install error");
        address appInfo = iGlobal(global).daoToAppInfo(number);
        (uint32 _ver,uint64 _index) = iappInfo(appInfo).getVersion(_number);
        bytes memory replaceData = iAppStore(appStore).replace(_index,_ver,_appIndex,_version,appInfo);
        (string memory _name,address[] memory con) = abi.decode(replaceData,(string,address[]));
        bytes memory replaceDataTo = abi.encode(_name,con,_version,_appIndex);
        iappInfo(appInfo).replace(_number,replaceDataTo);
    }
}