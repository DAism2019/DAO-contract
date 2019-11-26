from contract import getWallet
from web3.auto import w3

ONE_ETHER = 10 ** 18

def getInfo(address):
    contract = getWallet(address)
    print("当前钱包地址为:",address)
    print("当前钱包ETH数量为:",w3.eth.getBalance(address)/ONE_ETHER)
    owners = contract.functions.getOwners().call()
    print("当前钱包owner数量为:",len(owners))
    for _owner in owners:
        print("owner为:",_owner)

getInfo("0xD5432d126eC840Cd7a8fB57689d76c8aDBe9Ff23")
print("-------------------------")
getInfo("0x8d545BDC5f6F5B53FCCEbCe8eA5c17d8ebD0D064")
