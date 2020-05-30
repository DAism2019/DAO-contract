from contract import getWallet,WalletInfos
from privateKey import my_address
from web3.auto import w3
import time

ONE_ETHER = 10 ** 18


def myWallet():
    amount = WalletInfos.functions.getUserWalletCount(my_address).call()
    print("我创建的钱包数量为:",amount)
    for i in range(amount):
        address = WalletInfos.functions.userWallets(my_address,i).call()
        print("我创建的索引为:",i,"的钱包地址为:",address)
        infos = WalletInfos.functions.getWalletInfo(address).call()
        timestamp = time.localtime(infos[3])
        otherStyleTime = time.strftime("%Y--%m--%d %H:%M:%S", timestamp)
        print("钱包创建时间为:",otherStyleTime)
        print("钱包名称为:",infos[1])
        print("钱包模板为:",infos[2])
        print("------------------------")
        getInfo(address)


def getInfo(address):
    contract = getWallet(address)
    # print("当前钱包ETH数量为:",w3.eth.getBalance(address)/ONE_ETHER)
    count = contract.functions.transactionCount().call()
    print("当前所有交易的ID为:",count)
    transaction = contract.functions.transactions(count-1).call()
    print("最后一次交易的信息为:",transaction)
    owners = contract.functions.getOwners().call()
    print("当前钱包owner数量为:",len(owners))
    for _owner in owners:
        confirm = contract.functions.confirmations(count-1,_owner).call()
        print("owner为",_owner,"的用户是否确认:",confirm)

myWallet()
