from contract import WalletTemplateInfos,WalletTemplateOne
from privateKey import my_address, private_key
from web3.auto import w3

def getInfo():
    amount = WalletTemplateInfos.functions.getTemplateCount().call()
    print("当前钱包模板数量为:",amount)
    for i in range(amount):
        address = WalletTemplateInfos.functions.allTemplates(i).call()
        print("索引为:",i,"的模板地址为:",address)
        isFrozen = WalletTemplateInfos.functions.isFrozen(address).call()
        print("当前模板是否冻结:",isFrozen)
        print("--------------------------")


def addTemplate():
    nonce = w3.eth.getTransactionCount(my_address)
    unicorn_txn = WalletTemplateInfos.functions.addTemplate(WalletTemplateOne.address).buildTransaction({
        'nonce': nonce,
        'gasPrice': w3.toWei(10, 'gwei'),
    })
    signed_txn = w3.eth.account.signTransaction(
        unicorn_txn, private_key=private_key)
    hash = w3.eth.sendRawTransaction(signed_txn.rawTransaction)
    print("addTemplate交易已经发送")


getInfo()
addTemplate()
getInfo()
