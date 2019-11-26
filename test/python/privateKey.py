from os.path import dirname, abspath


def getInfo():
    path = dirname(dirname(dirname(abspath(__file__)))) + '/.env'
    content = open(path).read()
    strs = content.split('\n')
    address = (strs[0].split('='))[1]
    privateKey = (strs[1].split('='))[1]
    return address,privateKey


my_address,private_key = getInfo()
