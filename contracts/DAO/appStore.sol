pragma solidity ^0.8.0;
pragma abicoder v2;

interface iProduct{
    function isPayModule(address) external view returns(address);
}
//这里需要初始化第一件商品:owner,并且免费
contract AppStore{
    struct app{
        address payModule;
        string name;
        string[] constituteName;
        address[] constitute;
    }
    mapping(uint256 => app) private apps;
    mapping(uint256 => mapping(address => bool)) public isBuy;
    mapping(uint256 => bool) public isFree;
    mapping(string => uint256) public nameToIndex;
    address public products;
    uint256 public nextApp = 1;

    event AddApp(uint256 indexed,string indexed,string[],address[]);
    event UpdateApp(string indexed,string[],address[]);
    event FreeAppOrNot(string indexed _name,bool status,uint256 time);
    event Buy(string indexed _name,address indexed to,uint256);
    /**
    @dev 构造
    @param pro products合约的地址
    @param _names *
    @param cons *
     */
    constructor(address pro,string[] memory _names,address[] memory cons){
        require(keccak256(bytes(_names[0])) == keccak256("main"),"appStore/main");
        require(keccak256(bytes(_names[0])) == keccak256("proSelf"),"appStore/proSelf");
        products = pro;
        apps[nextApp].name = "owner";
        apps[nextApp].constituteName = _names;
        apps[nextApp].constitute = cons;
        isFree[1] = true;
        nextApp++;
    }
    //isProduct
    modifier isPay(){
        require(iProduct(products).isPayModule(msg.sender) != address(0),"appStore/isPay/not");
        _;
    }
    /**
    @dev 产品模块添加app
    @param _name app名字
    @param _names app组件名字
    @param cons app组件名字
     */
    function addApp(string memory _name,string[] memory _names,address[] memory cons) external isPay{
        require(nameToIndex[_name] == 0,"appStore/addApp/_name/inUse");
        require(_names.length == cons.length,"appStore/addApp/name_cons/length/not_equal");
        nameToIndex[_name] = nextApp;
        apps[nextApp].name = _name;
        apps[nextApp].constituteName = _names;
        apps[nextApp].constitute = cons;
        apps[nextApp].payModule = msg.sender;
        emit AddApp(nextApp,_name,_names,cons);
    }
    /**
    @dev 产品更新app
    @param _name *
    @param _names *
    @param cons *
     */
    function updateApp(string memory _name,string[] memory _names,address[] memory cons) external isPay{
        require(_names.length == cons.length || _names.length == 0,"appStore/updateApp/name_cons/length/not_equal");
        app storage appT = apps[nameToIndex[_name]];
        require(appT.payModule == msg.sender,"appStore/updateApp/paymodule_sender/not_equal");
        if(bytes(_name).length != 0){
            appT.name = _name;
        }
        if(_names.length != 0){
            appT.constituteName = _names;
        }
        appT.constitute = cons;
        emit UpdateApp(_name,_names,cons);
    }
    /**
    @dev 产品是否免费
    @param _name *
    @param status 产品是否免费的参数
     */
    function freeAppOrNot(string memory _name,bool status) external isPay{
        app storage appT = apps[nameToIndex[_name]];
        require(appT.payModule == msg.sender,"appStore/freeAppOrNot/paymodule_sender/not_equal");
        isFree[nameToIndex[_name]] = status;
        emit FreeAppOrNot(_name,status,block.timestamp);
    }
    /**
    @dev 产品来购买app
    @param _name *
    @param to_ app的购买者
     */
    function buy(string memory  _name,address to_) external isPay{
        app storage appT = apps[nameToIndex[_name]];
        require(appT.payModule == msg.sender,"appStore/buy/paymodule_sender/not_equal");
        isBuy[nameToIndex[_name]][to_] = true;
        emit Buy(_name,to_,block.timestamp);
    }
    /**
    @dev 安装app
    @param appNumber app编号
    @return name *
    @return names *
    @return cons *
     */
    function install(uint256 appNumber) external view returns(string memory name,string[] memory names,address[] memory cons){
        require(isBuy[appNumber][msg.sender] || isFree[appNumber],"appStore/install/isbuy/not");
        return (apps[appNumber].name,apps[appNumber].constituteName,apps[appNumber].constitute);
    }
    /**
    @dev 获取购买的bytes
    @param _name *
    @return to 产品地址
    @return callD call Bytes
     */
    function buy(string memory _name) external view returns(address to,bytes memory callD){
        app storage appT = apps[nameToIndex[_name]];
        to = appT.payModule;
        callD = abi.encodeWithSignature("buy(string)",_name);
    }
    
    function getLength(string memory _name) external view returns(uint256 len){
        len = apps[nameToIndex[_name]].constituteName.length;
    }
}