pragma solidity ^0.8.0;
pragma abicoder v2;

interface iGlobal{
    function daoVote(uint32) external view returns(address);
    function daoOs(uint32) external view returns(address);
    function init() external view returns(address);
}

interface iVote{
    function getVote(bool status,address _app) external view returns(address);
}

contract checkVote{
    address immutable global;
    uint32 public daoNumber;
    uint32 public internalVote;
    uint32 public internalDatabase;
    uint32 public externalVote;
    uint32 public externalDatabase;
    address public to;
    
    struct tempData{
        uint256 sumvotes;
        uint256 supportVotes;
    }
    
    tempData private temp;
    
    constructor(address _global){
        global = _global;
    }
    
    modifier self(){
        require(msg.sender == address(this),"Error : bot self");
        _;
    }
    
    function init(bytes memory voteData,uint32 _daoNumber,address _to) external {
        require(daoNumber == 0,"Error :has inited");
        require(iGlobal(global).init() == msg.sender,"Error,not init");
        (internalVote,externalVote,internalDatabase,externalDatabase) = abi.decode(voteData,(uint32,uint32,uint32,uint32));
        daoNumber = _daoNumber;
        to = _to;
    }
    
    function exec(uint256 _sumvotes,uint256 supportVotes,bytes memory _data,bytes memory others,bool status) external {
        require(check(msg.sender,status),"Error:not the right vote");
        temp.sumvotes = _sumvotes;
        temp.supportVotes = supportVotes;
        address(this).call(_data);
    }
    
    function check(address _form,bool status) internal view returns(bool){
        address chartT = iGlobal(global).daoVote(daoNumber);
        address rightFrom = iVote(chartT).getVote(status,address(this));
        return rightFrom == msg.sender;
    }
    
    function getTo() external view returns(address){
        return to;
    }
    
    function install(uint64 _number,uint32 _version) external self{
        if(2 * temp.supportVotes < temp.sumvotes){
            revert("not enough");
        }
        address os = iGlobal(global).daoOs(daoNumber);
        os.call(msg.data);
    }
}