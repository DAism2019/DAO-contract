pragma solidity ^0.8.0;
pragma abicoder v2;

interface iGlobalD{
    function daoOs(uint32) external view returns(address);
    function init() external view returns(address);
}

contract databaseChart{
    mapping(uint32 => address) public database;
    mapping(address => uint32) public internals;
    mapping(address => uint32) public externals;
    uint32 public index = 2;
    address immutable global;
    uint32 immutable daoNumber;
    
    constructor(address _global,address _database,uint32 _daoNumber){
        database[1] = _database;
        daoNumber = _daoNumber;
        global = _global;
    }
    
    function setdatabase(address _database) external {
        address os = iGlobalD(global).daoOs(daoNumber);
        require(msg.sender == os,"Error :not a os");
        database[index] = _database;
        index ++;
    }
    
    function changedatabase(address _database,uint32 _index) external {
        address os = iGlobalD(global).daoOs(daoNumber);
        require(msg.sender == os,"Error :not a os");
        database[_index] = _database;
    }
    
    function addMap(address _app,uint32 _internal,uint32 _external) external {
        require(msg.sender == iGlobalD(global).init(),"Error: not the init address");
        internals[_app] = _internal;
        externals[_app] = _external;
    }
}