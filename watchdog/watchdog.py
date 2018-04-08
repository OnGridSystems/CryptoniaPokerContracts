#!/usr/bin/env python

import json
from web3 import Web3, HTTPProvider, Account

with open('crowdsale_abi.json', 'r') as file:
    crowdsale_abi = json.loads(file.read())

with open('token_abi.json', 'r') as file:
    token_abi = json.loads(file.read())

ico_json = "/home/cryptonia/public_html/ico.json"

w3 = Web3(HTTPProvider('https://mainnet.infura.io/'))
token_addr = w3.toChecksumAddress("0x0809bD190C94F4408e691C410E67BFf0DF5d225d")
token = w3.eth.contract(abi=token_abi, address=token_addr)
crowdsale_addr = w3.toChecksumAddress("0x510093014fa8EE0cF957b591B581573D7D6135aD")
crowdsale = w3.eth.contract(abi=crowdsale_abi, address=crowdsale_addr)

raisedETH = float(crowdsale.functions.weiRaised().call())/10**18
soldCPC = float(token.functions.totalSupply().call())/100
ico_json_dict = {'raisedETH' : raisedETH, 'soldCPC': soldCPC}
print(ico_json_dict)

with open(ico_json, 'w') as outfile:
    json.dump(ico_json_dict, outfile)

print("written to the file")
