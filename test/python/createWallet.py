from contract import WalletAdmin,WalletInfos
from privateKey import my_address, private_key
from web3.auto import w3
import time

ONE_ETHER = 10 ** 18

def allWallet():
    nonce = WalletInfos.functions.nonce().call()
    print("当前钱包数量为:",nonce)
    for i in range(nonce):
        address = WalletInfos.functions.walletAddressById(i+1).call()
        print("当前索引为:",i,"的钱包地址为:",address)
        print("------------------------")


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


def createWallet():
    fee = WalletAdmin.functions.getCreateFee().call()
    print('当前创建钱包的费用为:',fee/ONE_ETHER,'ETH')
    name="NaturalDao"
    owners = [my_address,'0x8Df5B73CD52AC4837e761277a3C769f7F50A0cd2']
    required = len(owners)
    template_index = 0
    args = (name,owners,required,template_index)
    nonce = w3.eth.getTransactionCount(my_address)
    unicorn_txn = WalletAdmin.functions.createWallet(*args).buildTransaction({
        'nonce': nonce,
        'value':fee,
        'gasPrice': w3.toWei(10, 'gwei'),
    })
    signed_txn = w3.eth.account.signTransaction(
        unicorn_txn, private_key=private_key)
    hash = w3.eth.sendRawTransaction(signed_txn.rawTransaction)
    print("createWallet交易已经发送")


allWallet()
myWallet()
createWallet()
allWallet()
myWallet()
