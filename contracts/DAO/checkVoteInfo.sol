pragma solidity ^0.8.0;
pragma abicoder v2;


contract checkVoteInfo{
    
    function init(bytes memory voteData,uint32 _daoNumber,address _to) external view returns(bytes memory ) {
        return msg.data;
    }
    
    function init(bytes memory voteData,uint32 _daoNumber,address _to) external view returns(bytes memory ) {
        return msg.data;
    }
    
    function fourPara(uint32 one,uint32 two, uint32 three,uint32 four) external view returns(bytes memory) {
        return abi.encode(one,two,three,four);
    }
        
    
    
}