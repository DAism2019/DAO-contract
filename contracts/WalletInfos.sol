pragma solidity ^0.5.0;

contract WalletHubInterface {
    function getWalletAdminAddress() external view returns(address);
}

contract WalletInfos {
    struct Infos {
        address creator;
        string name;
        uint templateIndex;
        uint createTime;
        //todo
        /* string descriptions; */
        /* string website; */
    }
    uint public nonce;                                                  //record the amout of wallet
    mapping(uint => address) public walletAddressById ;                                   //enum all wallets   id => address
    WalletHubInterface public wallet_hub;                                  // the instance of wallet_hub contract
    mapping(address => address[]) public userWallets;                   // all wallets  creator => wallet_address[]
    mapping(address => Infos) private _allWalletInfos;                  //record the infos of all wallet
    mapping(string => address) private _walletAddresses;                 // name => address


    modifier onlyWalletAdmin {
        require(msg.sender == wallet_hub.getWalletAdminAddress(),"WalletInfos:permission denied");
        _;
    }

    constructor(address wallet_hub_address) public {
        require(wallet_hub_address != address(0),"WalletInfos: zero_address");
        wallet_hub = WalletHubInterface(wallet_hub_address);
    }

    function getWalletInfoById(uint id) external view returns(address,address,string memory,uint,uint) {
        /**
            @dev return infos of a wallet
            @param id The id of the wallet
            @return Address of wallet ,creator、name、template_index、createTime of wallet
        */
        require(id > 0 && id <=nonce, "WalletInfos: id out of bounds");
        address wallet = walletAddressById[id];
        Infos memory info = _allWalletInfos[wallet];
        return (wallet,info.creator,info.name,info.templateIndex,info.createTime);
    }

    function getWalletInfo(address wallet) external view returns(address,string memory,uint,uint) {
        /**
            @dev return infos of a wallet
            @param wallet The address of the wallet
            @return Creator、name、template_index、createTime of wallet
        */
        Infos memory info = _allWalletInfos[wallet];
        return (info.creator,info.name,info.templateIndex,info.createTime);
    }

    function getWalletInfoByName(string calldata name) external view returns(address,address,string memory,uint,uint) {
        /**
            @dev return infos of a wallet
            @param name The name of the wallet
            @return  Address of wallet creator、name、template_index、createTime of wallet
        */
        address wallet = _walletAddresses[name];
        Infos memory info = _allWalletInfos[wallet];
        return (wallet,info.creator,info.name,info.templateIndex,info.createTime);
    }


    function hasRegister(string calldata name) external view returns(bool) {
        /**
            @dev Judge a name has been registered
            @param name The name that will be registered
        */
        return _walletAddresses[name] != address(0);
    }

    function getUserWalletCount(address creator) external view returns(uint) {
        /**
            @dev  Get the amount of wallets created by user
            @param creator The creator of wallets
        */
        return userWallets[creator].length;
    }

    function saveWalletInfo(address creator,address wallet,string calldata name,uint templateIndex) external onlyWalletAdmin returns(uint)  {
        /**
            @dev  Save infos of wallet that has been created
            @param creator The creator of wallet
            @param wallet The address of wallet
            @param name The name of wallet
            @param templateIndex The template_index of wallet
            @return Amount of wallets
        */
        require(wallet != address(0),"WalletInfos: zero_address");
        require(_walletAddresses[name] == address(0),"WalletInfos: name has been registered");
        nonce++;
        walletAddressById[nonce] = wallet;
        _allWalletInfos[wallet] = Infos(creator,name,templateIndex,block.timestamp);
        userWallets[creator].push(wallet);
        _walletAddresses[name] = wallet;
        return nonce;
    }
}
