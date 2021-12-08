pragma solidity ^0.8.0;
pragma abicoder v2;
import "./voteChart.sol";
import "./voteDatabase.sol";
import "./vote.sol";
import "./databaseChart.sol";

contract iVote{
    function create(bytes memory databaseData,address global,uint32 daoNumber)
        external 
        returns(bytes memory returnsData)
    {
        (address os,address[] memory mem,uint256[] memory power) = abi.decode(databaseData,(address,address[],uint256[]));
         voteDatabase voteDatabaseT = new voteDatabase(os,mem,power);
         databaseChart databaseChartT = new databaseChart(global,address(voteDatabaseT),daoNumber);
         
         vote voteT = new vote(global,daoNumber);
         voteChart voteChartT = new voteChart(address(voteT),global,daoNumber);
         return abi.encode(address(voteDatabaseT),address(databaseChartT),address(voteChartT),address(voteT));
    }
}