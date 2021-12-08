pragma solidity ^0.8.0;
pragma abicoder v2;

interface iGlobal{
    function osDao(address os)external view returns(uint32);
}

interface iPayModule{
    function isBuy(address,uint64) external view returns(bool);
}

contract appStore{
    struct app{
        string name;
        address[] constitute;
        uint8[] types;
    }
    mapping(uint64=>mapping(uint32 => app)) private apps;
    mapping(uint64 => address) public owner;
    mapping(uint64 => address) public payModule;
    mapping(uint64 => uint32) public lastest;
    address immutable global;
    uint64 public nextApp=1;
    address public manager;
    bool public isOs;
    bool public isPayModule;
    
    constructor(address _global,address _manager){
        global = _global;
        manager = _manager;
    }
    
    function _addApp(address _payModule,string memory _name,address[] memory _constitute,uint8[] memory _types,uint64 _appIndex) internal {
        require(_constitute.length == _types.length);
        uint32 version = lastest[nextApp];
        version ++;
        apps[_appIndex][version].name = _name;
        apps[_appIndex][version].types = _types;
        apps[_appIndex][version].constitute = _constitute;
        payModule[_appIndex] = _payModule;
        lastest[_appIndex] = version;
    }
    function chageIsOs() external {
        require(msg.sender == manager,"Error,no permision");
        isOs = !isOs;
    }
    function changeIsPayModule() external {
        require(msg.sender == manager,"Error,no permision");
        isPayModule = !isPayModule;
    }
    function addApp(address _payModule,string memory _name,address[] memory _constitute,uint8[] memory _types) external returns(uint64){
        owner[nextApp] = msg.sender;
        if(isOs){
            require(iGlobal(global).osDao(msg.sender) != 0,"Error : not a dao");
        }
        _addApp(_payModule,_name,_constitute,_types,nextApp);
        nextApp++;
        return nextApp-1;
    }
    function updateApp(address _payModule,string memory _name,address[] memory _constitute,uint8[] memory _types,uint64 _appIndex) external{
        require(owner[_appIndex] == msg.sender,"not a owner");
        _addApp(_payModule,_name,_constitute,_types,_appIndex);
    }
    function install(uint64 appNumber,uint32 _version,address appInfo) external view returns(bytes memory ){
        if(isPayModule){
            require(iPayModule(payModule[appNumber]).isBuy(appInfo,appNumber),"no buy");
        }
        bytes memory installData = abi.encode(apps[appNumber][_version].name,apps[appNumber][_version].constitute,apps[appNumber][_version].types);
        return installData;
    }
    function update(uint64 appNumber,uint32 _version,address appInfo) external view returns(bytes memory ){
        require(_version < lastest[appNumber],"Error:is the lastest");
        app memory old = apps[appNumber][_version];
        app memory _new = apps[appNumber][lastest[appNumber]];
        require(_new.constitute.length >= old.constitute.length,"less than");
        uint256 cha = _new.constitute.length - old.constitute.length;
        return abi.encode(_new.name,_new.constitute,_new.types,cha,lastest[appNumber]);
    }
    function replace(uint64 appNumber1,uint32 _version1,uint64 appNumber2,uint32 _version2,address appInfo) external view returns(bytes memory ){
        if(isPayModule){
            require(iPayModule(payModule[appNumber2]).isBuy(appInfo,appNumber2),"no buy");
        }
        app memory old = apps[appNumber1][_version1];
        app memory _new = apps[appNumber2][_version2];
        //require(old.constitute.length == _new.constitute.length,"length is not same");
        for(uint256 i = 0;i < old.constitute.length;i++){
            require(old.types[i] == _new.types[i],"Error:type is not same");
        }
        bytes memory replaceData = abi.encode(_new.name,_new.constitute);
        return replaceData;
    }
}