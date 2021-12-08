pragma solidity ^0.8.0;
pragma abicoder v2;
import "./DELEGATE.sol";

interface iAppStore{
    function install(uint256 appNumber) external view returns(string memory name,string[] memory names,address[] memory cons);
}
interface iApp{
    function lock(address _lock) external;
}
interface iOverview{
    function setApp(address[] memory apps,uint256 id) external;
    function setApp(address app,uint256 id) external;
}
//可以结合利用稳定的多签合约来管理
contract OS{
    struct app{
        string name;
        address[] delegates;
        //can see if need to update
        address[] constitute;
        mapping(address => uint256) delegateIndex;
        mapping(address => uint256) constituteIndex;
        mapping(address => string) constituteName;
        mapping(string => address) nameToConstitute;
        //it's no need to know that if it is inited
        //mapping(address => bool) inited;
        bool isUninstall;
        address lockAddress;
    }
    address public owner;
    uint256 public ownerIndex;
    mapping(address => mapping(bytes32 => bool)) public rightOf;
    mapping(uint256 => mapping(bytes32 => bool)) public rightAppOf;
    mapping(uint256 => app) private apps;
    //store constitute address
    mapping(uint256 => uint256) public appStoreNumber;
    //not inuse
    mapping(address => uint256) public delegatesOf;
    mapping(string => uint256) public nameToIndex;
    uint256 public appNext = 1;
    //can cosider remove the index of app

    address public outDoor;
    address public appStore;
    address public overview;

    /**
    @dev 构造
    @param _owner 拥有者
    @param _appStore appStore的地址
     */
    constructor(address _owner,address _appStore,address _overview){
        owner = _owner;
        appStore = _appStore;
        overview = _overview;
    }

    //"owner"'s app的index恒为1
    modifier ownerOnly(){
        require(msg.sender == owner || delegatesOf[msg.sender] == ownerIndex,"OS/owner/not");
        _;
    }

    modifier self(){
        require(msg.sender == address(this) || msg.sender == owner,"OS/self/not");
        _;
    }

    function changeOnwer() external ownerOnly{
        owner = address(0);
    }

    function transferOwnerShip(address newOwner) external ownerOnly{
        require(newOwner != address(0),"OS/transferOwnerShip/zero_address");
        owner = newOwner;
    }
    /**
    @dev 授权
    @param to_ 被授权的app地址
    @param right 授权能力
    @param status 授权状态
     */
    function approveRight(address to_,bytes32 right,bool status)external ownerOnly{
        rightOf[to_][right] = status;
    }
    /**
    @dev 授权app
    @param appIndex app编号
    @param right *
    @param status *
     */
    function approveAppRight(uint256 appIndex,bytes32 right,bool status)external ownerOnly{
        rightAppOf[appIndex][right] = status;
    }
    /**
    @dev 设置owner的app编号
    @param newIndex app编号
     */
    function setOwnerIndex(uint256 newIndex) external ownerOnly{
        require(newIndex > 0,"OS/setOwnerIndex/newIndex/zero");
        ownerIndex = newIndex;
        emit SetOwnerIndex(newIndex,block.timestamp);
    }
    event SetOwnerIndex(uint256 indexed newIndex,uint256);
    
    function changeLock(address _new,string memory _name) external ownerOnly{
        apps[nameToIndex[_name]].lockAddress = _new;
        emit ChangeLock(_new,block.timestamp);
    }
    event ChangeLock(address indexed new,uint256 time);
    //it can update
    /**
    @dev 安装
    @param _appStoreNumber app在appStore的编号
     */
    function install(uint256 _appStoreNumber,address lockAddress) external {
        beforeSelf(msg.data);
        (string memory _name,string[] memory names,address[] memory _constitute) = iAppStore(appStore).install(_appStoreNumber);
        apps[appNext].name = _name;
        require(nameToIndex[_name] == 0,"OS/install/appname/inuse");
        nameToIndex[_name] = appNext;
        require(_constitute.length == names.length,"OS/install/length/names_constitute/not_equal");
        for(uint256 i = 0;i < names.length;i++){
            apps[appNext].constitute = _constitute;
            apps[appNext].constituteName[_constitute[i]] = names[i];
            //constituteOf[_constitute[i]] = appNext;
            apps[appNext].nameToConstitute[names[i]] = _constitute[i];
        }
        for(uint256 i = 0;i < _constitute.length;i++){
            Delegate deleAddress = new Delegate(address(this),appNext,i);
            apps[appNext].constituteIndex[_constitute[i]] = i+1;
            apps[appNext].delegates.push(address(deleAddress));
            delegatesOf[address(deleAddress)] = appNext;
            iApp(address(deleAddress)).lock(lockAddress);
            _constitute[i] = address(deleAddress);
            apps[appNext].delegateIndex[_constitute[i]] = i+1;
        }
        apps[appNext].lockAddress = lockAddress;
        iOverview(overview).setApp(_constitute,appNext);
        appNext ++;
        emit Install(_appStoreNumber,block.timestamp,lockAddress);
    }
    event Install(uint256 indexed _appStoreNumber,uint256,address lock);
    /**
    @dev 更新
    @param _appStoreNumber *
     */
    function update(uint256 _appStoreNumber) external {
        beforeSelf(msg.data);
        (string memory _name,string[] memory names,address[] memory _constitute) = iAppStore(appStore).install(_appStoreNumber);
        require(_constitute.length == names.length,"OS/update/length/names_constitute/not_equal");
        uint256 id = nameToIndex[_name];
        require(id > 0,"os:id not in use");
        uint256 length = apps[id].constitute.length;
        require(_constitute.length >= length,"OS/update/less_length");
        for(uint256 i = 0;i < length;i++){
            if(apps[id].constitute[i] != _constitute[i]){
                apps[id].constitute[i] = _constitute[i];
            }
        }
        if(_constitute.length - length > 0){
            address allApp = new address[](_constitute.length - length)
            for(uint256 i = 0;i < _constitute.length - length;i++){
                Delegate deleAddress = new Delegate(address(this),id,i+length);
                apps[appNext].constituteIndex[_constitute[i+length]] = i+1+length;
                apps[appNext].delegates.push(address(deleAddress));
                delegatesOf[address(deleAddress)] = id;
                iApp(address(deleAddress)).lock(lockAddress);
                allApp[i] = address(deleAddress);
                apps[appNext].delegateIndex[allApp[i]] = i+1+length;
            }
            iOverview(overview).setApp(allApp,id);
        }
        
        emit Update1(_appStoreNumber,block.timestamp);
    }
    event Update1(uint256 indexed _appStoreNumber,uint256);
    /**
    @dev 更新app
    @param appName *
    @param constituteName 组件名字
    @param newCon 新组件
     */
    function update(string memory appName,string memory constituteName,address newCon) external{
        beforeSelf(msg.data);
        _update(appName,constituteName,newCon);
        emit Update2(appName,constituteName,newCon,block.timestamp);
    }
    event Update2(string indexed appName,string constituteName,address newCon,uint256);
    //it can update by yourself
    function _update(string memory appName,string memory constituteName,address newCon) internal {
        address tempAddress = getAddress(appName,constituteName);
        require( tempAddress != address(0),"OS/update/getAddress/zero_address");
        uint256 tempIndex = apps[nameToIndex[appName]].constituteIndex[tempAddress];
        apps[nameToIndex[appName]].constitute[tempIndex] = newCon;
    }
    /**
    @dev 添加新组件
    @param appName *
    @param constituteName *
    @param newCon *
     */
    function addConstitute(string memory appName,string memory constituteName,address newCon) external {
        beforeSelf(msg.data);
        require( getAddress(appName,constituteName) == address(0),"OS/addConstitute/getAddress/inuse");
        uint256 index = nameToIndex[appName];
        uint256 nextIndex = apps[index].delegates.length;
        Delegate tempD = new Delegate(address(this),index,nextIndex);
        delegatesOf[address(tempD)] = index;
        apps[index].constitute.push(newCon);
        apps[index].delegates.push(address(tempD));
        apps[index].constituteIndex[newCon] = apps[index].constitute.length;
        apps[index].constituteName[newCon] = constituteName;
        emit AddConstitute(appName,constituteName,newCon,block.timestamp);
    }
    event AddConstitute(string indexed appName,string constituteName,address newCon,uint256);
    /**
    @dev 使app不可用
     */
    function disable(uint256 appIndex) external {
        beforeSelf(msg.data);
        apps[appIndex].isUninstall = true;
        emit Disable(appIndex,block.timestamp);
    }
    event Disable(uint256 indexed appIndex,uint256);
    /**
    @dev 使app可用
     */
    function enable(uint256 appIndex) external {
        beforeSelf(msg.data);
        apps[appIndex].isUninstall = false;
        emit Enable(appIndex,block.timestamp);
    }
    event Enable(uint256 indexed appIndex,uint256);
    /**
    @dev app调用时，需要设置的调用地址 */
    function setOut(address to_) external {
        outDoor = to_;
    }
    /**
    @dev 用于app对外调用
     */
    fallback(bytes calldata _in) external payable returns(bytes memory){
        beforeSelf(_in);
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

    function transferETH(address to_,uint256 amount)external{
        beforeSelf(msg.data);
        payable(to_).transfer(amount);
        emit TransferETH(to_,amount,block.timestamp);
    }
    event TransferETH(address indexed to_,uint256 amount,uint256);
    function getAddress(uint256 index,uint256 conIndex) external view returns(address){
        return apps[index].constitute[conIndex];
    }

    function getAddress(string memory appName,string memory constituteName) public view returns(address){
        app storage appT = apps[nameToIndex[appName]];
        address con = appT.nameToConstitute[constituteName];
        uint256 index = appT.constituteIndex[con];
        return appT.delegates[index-1];
    }

    function verify(address to_,string memory appName,string memory constituteName) external view returns(bool){
        return getAddress(appName,constituteName) == to_;
    }
    
    function getLock(string memory _name) external view returns(address){
        return apps[nameToIndex[_name]].lockAddress;
    }
    /**
    @dev 认证权限 */
    function beforeSelf(bytes memory _in) internal view {
        require(!apps[delegatesOf[msg.sender]].isUninstall,"OS/Fallback/app/disable");
        bytes4 callAPI4;
        //bytes memory callData_ = calldata;
        for(uint256 i = 0;i < 4;i++){
            callAPI4 |= bytes4(_in[i]&0xFF)>>(i*8);
        }
        bytes32 choose = bytes32(callAPI4) | (bytes32(bytes20(outDoor)) >>32);
        bool right1 = rightOf[msg.sender][choose];
        bool right2 = rightAppOf[delegatesOf[msg.sender]][choose];
        require(right1 || right2 ,"OS/Fallback/no_right");
    }
}