pragma solidity ^0.8.0;
pragma abicoder v2;

contract appInfo{
    struct Info{
        string name;
        uint64 appIndex;
        uint32 version;
        address[] delegates;
        //can see if need to update
        address[] constitute;
        uint256[] number;
        mapping(address => uint256) index;
    }
    
    mapping(uint256 => Info) private appsInfo;
    mapping(address => uint256) public numberOfApp;
    mapping(uint256 => bool) public isUninstall;
    address public installA;
    uint32 public daoNumber;
    uint32 public appNext = 1;
    
    uint256 constant getAppNumber = 2**65-1 << 16;
    
    constructor(uint32 _daoNumber,address _install)  {
        daoNumber = _daoNumber;
        installA = _install;
    }
    
    modifier only(){
        require(msg.sender == installA ,"ERROR0x0002:wrong permision");
        _;
    }
    
    // function init(address _install,address _uninstall) external {
    //     require(_install != address(0) && install == address(0),"ERROR0x0001:appInfo init error");
    //     install = _install;
    //     uninstall = _uninstall;
    // }
    
    function install(uint64 _appIndex,bytes memory appData)external only{
        uint256 appNumber = uint256(daoNumber) << 32  | uint256(appNext);
        appNext ++;
        (string memory _name,address[] memory _constitute,address[] memory _delegates,uint16[] memory _number,uint32 _version) = abi.decode(appData,(string,address[],address[],uint16[],uint32));
        appsInfo[appNumber].name = _name;
        appsInfo[appNumber].delegates = _delegates;
        appsInfo[appNumber].constitute = _constitute;
        uint256[] memory _number256 = new uint256[](_number.length);
        for(uint256 i = 0;i < _number.length;i++){
            _number256[i] = appNumber << 16 + uint256(_number[i]); 
        }
        appsInfo[appNumber].number = _number256;
        for(uint256 i = 0;i < _delegates.length;i++){
            appsInfo[appNumber].index[_delegates[i]] = i+1;
            numberOfApp[_delegates[i]] = _number256[i];
        }
        appsInfo[appNumber].version = _version;
        appsInfo[appNumber].appIndex = _appIndex;
        emit Install(_appIndex,appNumber,_name);
    }
    event Install(uint64 indexed index,uint256 appNumber,string  _name);
    
    function uninstall(uint32 _appNumber) external only{
        uint256 appNumber = uint256(daoNumber) << 32  | uint256(_appNumber);
        isUninstall[appNumber] = true;
    }
    
    function recover(uint32 _appNumber) external only{
        uint256 appNumber = uint256(daoNumber) << 32 | uint256(_appNumber);
        isUninstall[appNumber] = false;
    }
    
    function update(uint32 _appNumber,bytes memory updateData) external only{
        (string memory _name,address[] memory _constitute,address[] memory _delegates,uint16[] memory _number,uint32 _version) = abi.decode(updateData,(string,address[],address[],uint16[],uint32));
        uint256 appNumber = uint256(daoNumber) << 32  | uint256(_appNumber);
        uint256 len = appsInfo[appNumber].constitute.length;
        appsInfo[appNumber].name = _name;
        appsInfo[appNumber].constitute = _constitute;
        uint256[] memory _number256 = new uint256[](_number.length);
        for(uint256 i = 0;i < _number.length;i++){
            _number256[i] = appNumber << 16 + uint256(_number[i]); 
        }
        appsInfo[appNumber].number = _number256;
        for(uint256 i = 0;i < _delegates.length;i++){
            appsInfo[appNumber].delegates.push(_delegates[i]);
            appsInfo[appNumber].index[_delegates[i]] = len+i+1;
            numberOfApp[_delegates[i]] = _number256[i];
        }
        appsInfo[appNumber].version = _version;
    }
    
    function replace(uint32 _appNumber,bytes memory replaceData) external only{
        (string memory _name,address[] memory _constitute,uint32 _version,uint64 _appIndex) = abi.decode(replaceData,(string,address[],uint32,uint64));
        uint256 appNumber = uint256(daoNumber) << 32  | uint256(_appNumber);
        appsInfo[appNumber].appIndex = _appIndex;
        appsInfo[appNumber].version = _version;
        appsInfo[appNumber].constitute = _constitute;
        appsInfo[appNumber].name = _name;
    }
    
    function isApp(address appAddress) public view returns(bool){
        uint256 _appNumber = getAppNumber & numberOfApp[appAddress];
        return !(numberOfApp[appAddress] == 0 && !isUninstall[_appNumber]);
    }
    
    function getAddress(uint32 _appNumber,uint8 _number) public view returns(address){
        uint256 appNumber = uint256(daoNumber) << 32 | uint256(_appNumber);
        return appsInfo[appNumber].constitute[_number];
    }
    
    function getAddressDele(uint32 _appNumber,uint8 _number) public view returns(address){
        uint256 appNumber = uint256(daoNumber) << 32 | uint256(_appNumber);
        return appsInfo[appNumber].delegates[_number];
    }
    
    function getVersion(uint32 _appnumber) public view returns(uint32,uint64){
        uint256 appNumber = uint256(daoNumber) << 32 | uint256(_appnumber);
        return (appsInfo[appNumber].version,appsInfo[appNumber].appIndex);
    }
    
    function getAppNext() public view returns(uint32){
        return appNext;
    }
    
    function getAppMessage(uint32 _appNumber) public view returns(string memory,address[] memory){
        uint256 appNumber = uint256(daoNumber) << 32 | uint256(_appNumber);
        return (appsInfo[appNumber].name,appsInfo[appNumber].delegates);
    }
}