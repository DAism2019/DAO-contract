from contract import WalletHub,WalletAdmin
from privateKey import my_address, private_key
from web3.auto import w3

ONE_ETHER = 10 ** 18
ANOTHER_ADDRESS = '0x8Df5B73CD52AC4837e761277a3C769f7F50A0cd2'

def getInfo():
    isUpgrade = WalletHub.functions.isUpgrade().call()
    print("当前合约是否升级过:",isUpgrade)
    if isUpgrade:
        instance = WalletHub.functions.instance().call()
        print("当前合约升级后的地址为:",instance)
    beneficiary = WalletHub.functions.getBeneficiary().call()
    print("当前服务费汇聚地址为:",beneficiary)
    fee = WalletHub.functions.getCreateFee().call()
    print("当前创建钱包的服务费为:",fee/ONE_ETHER,"ETH")
    wallet_admin = WalletHub.functions.getWalletAdminAddress().call()
    print("当前WalletAdmin合约的地址为:",wallet_admin)

def setWalletAdminAddress():
    nonce = w3.eth.getTransactionCount(my_address)
    unicorn_txn = WalletHub.functions.setWalletAdminAddress(WalletAdmin.address).buildTransaction({
        'nonce': nonce,
        'gasPrice': w3.toWei(10, 'gwei'),
    })
    signed_txn = w3.eth.account.signTransaction(
        unicorn_txn, private_key=private_key)
    hash = w3.eth.sendRawTransaction(signed_txn.rawTransaction)
    print("setWalletAdminAddress交易已经发送")


def setBeneficiary():
    nonce = w3.eth.getTransactionCount(my_address)
    unicorn_txn = WalletHub.functions.setBeneficiary(ANOTHER_ADDRESS).buildTransaction({
        'nonce': nonce,
        'gasPrice': w3.toWei(10, 'gwei'),
    })
    signed_txn = w3.eth.account.signTransaction(
        unicorn_txn, private_key=private_key)
    hash = w3.eth.sendRawTransaction(signed_txn.rawTransaction)
    print("setBeneficiary交易已经发送")


def setCreateFee():
    nonce = w3.eth.getTransactionCount(my_address)
    unicorn_txn = WalletHub.functions.setCreateFee(ONE_ETHER).buildTransaction({
        'nonce': nonce,
        'gasPrice': w3.toWei(10, 'gwei'),
    })
    signed_txn = w3.eth.account.signTransaction(
        unicorn_txn, private_key=private_key)
    hash = w3.eth.sendRawTransaction(signed_txn.rawTransaction)
    print("setCreateFee交易已经发送")


def setup():
    setWalletAdminAddress()
    setBeneficiary()
    setCreateFee()

getInfo()
setWalletAdminAddress()
getInfo()
