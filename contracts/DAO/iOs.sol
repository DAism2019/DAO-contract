pragma solidity ^0.8.0;
pragma abicoder v2;
import "./appInfo.sol";
import "./osT.sol";

contract iOs{
    function create(bytes memory appInfoData) external returns(address,address){
        (uint32 daoNumber,address _install) = abi.decode(appInfoData,(uint32,address));
        appInfo appInfoT = new appInfo(daoNumber,_install);
        os osT = new os(address(appInfoT));
        return (address(appInfoT),address(osT));
    }
}