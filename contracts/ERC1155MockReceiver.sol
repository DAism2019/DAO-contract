pragma solidity ^0.5.0;

import "./Common.sol";
import "./IERC1155TokenReceiver.sol";

// Contract to test safe transfer behavior.
contract ERC1155MockReceiver is ERC1155TokenReceiver, CommonConstants {

    function onERC1155Received(address , address , uint256 , uint256 , bytes calldata ) external returns(bytes4) {
        return ERC1155_ACCEPTED;
    }

    function onERC1155BatchReceived(address , address , uint256[] calldata , uint256[] calldata , bytes calldata ) external returns(bytes4) {
        return ERC1155_BATCH_ACCEPTED;
    }

    // ERC165 interface support
    function supportsInterface(bytes4 interfaceID) public pure returns (bool) {
        return  interfaceID == 0x4e2312e0;      // ERC1155_ACCEPTED ^ ERC1155_BATCH_ACCEPTED;
    }
}
