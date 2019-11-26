from web3.auto import w3
from json import loads
from os.path import dirname, abspath

def getWallet(address):
    path = dirname(dirname(dirname(abspath(__file__))))
    template_one_abi_path = path + '/build/contracts/WalletTemplateOne.json'
    contract_template_one_abi = loads(
        open(template_one_abi_path).read())['abi']
    contract_template_one = w3.eth.contract(
        address, abi=contract_template_one_abi)
    return contract_template_one

def init():
    path = dirname(dirname(dirname(abspath(__file__))))
    all_address_path = path + '/test/address.json'
    all_address = loads(open(all_address_path).read())

    wallet_hub_abi_path = path + '/build/contracts/WalletHub.json'
    template_infos_abi_path = path + '/build/contracts/WalletTemplateInfos.json'
    wallet_infos_abi_path = path + '/build/contracts/WalletInfos.json'

    wallet_admin_abi_path = path + '/build/contracts/WalletAdmin.json'


    contract_wallet_hub_abi = loads(open(wallet_hub_abi_path).read())['abi']
    contract_template_infos_abi = loads(
        open(template_infos_abi_path).read())['abi']
    contract_wallet_infos_abi = loads(
        open(wallet_infos_abi_path).read())['abi']

    contract_wallet_admin_abi = loads(
        open(wallet_admin_abi_path).read())['abi']

    contract_wallet_hub = w3.eth.contract(
        address=all_address["WalletHub"], abi=contract_wallet_hub_abi)
    contract_template_infos = w3.eth.contract(
        address=all_address["WalletTemplateInfos"], abi=contract_template_infos_abi)
    contract_wallet_infos = w3.eth.contract(
        address=all_address["WalletInfos"], abi=contract_wallet_infos_abi)
    contract_wallet_admin = w3.eth.contract(
        address=all_address["WalletAdmin"], abi=contract_wallet_admin_abi)

    return contract_wallet_hub, contract_template_infos, contract_wallet_infos, contract_wallet_admin


WalletHub, WalletTemplateInfos, WalletInfos, WalletAdmin = init()

getWallet
