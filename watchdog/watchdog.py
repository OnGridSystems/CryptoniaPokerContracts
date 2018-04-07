#!/usr/bin/env python

import json
from web3 import Web3, HTTPProvider, Account

with open('crowdsale_abi.json', 'r') as file:
    crowdsale_abi = json.loads(file.read())

with open('token_abi.json', 'r') as file:
    token_abi = json.loads(file.read())

w3 = Web3(HTTPProvider('https://mainnet.infura.io/'))
token_addr = w3.toChecksumAddress("0x0809bD190C94F4408e691C410E67BFf0DF5d225d")
token = w3.eth.contract(abi=token_abi, address=token_addr)
crowdsale_addr = w3.toChecksumAddress("0x510093014fa8EE0cF957b591B581573D7D6135aD")
crowdsale = w3.eth.contract(abi=crowdsale_abi, address=crowdsale_addr)


print("Token Total Supply: %s" % token.functions.totalSupply().call())
print("Crowdsale weiRaised: %s" % crowdsale.functions.weiRaised().call())
phase_index = crowdsale.functions.getCurrentPhaseIndex().call()
print("Crowdsale CurrentPhaseIndex: %s" % phase_index)
print("Crowdsale CurrentPhase: %s" % crowdsale.functions.phases(phase_index).call())
