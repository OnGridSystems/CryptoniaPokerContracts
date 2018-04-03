# Cryptonia Poker Chips and Crowdsale (ICO) contracts
[![Build Status](https://travis-ci.org/OnGridSystems/CryptoniaPokerContracts.svg?branch=master)](https://travis-ci.org/OnGridSystems/CryptoniaPokerContracts)

Cryptonia digital assets are ERC-20 compatible Ethereum tokens. Tokens sold out to investors during ICO using Crowdsale 
contracts or issued (minted) manually by the owner for any given account. The token holder (beneficiary) is able to store, 
burn or send this token to any other address. In the future the tokens can be utilized by Cryptonia application (out of 
scope of this spec).

Cryptonia Poker Ethereum contracts suite consists of
* Cryptonia Poker Chips token (CPC) at [0x0809bD190C94F4408e691C410E67BFf0DF5d225d](https://etherscan.io/address/0x0809bD190C94F4408e691C410E67BFf0DF5d225d) - the main Chip of Cryptonia Poker game;
* Crowdsale contract at [0x510093014fa8EE0cF957b591B581573D7D6135aD](https://etherscan.io/address/0x510093014fa8EE0cF957b591B581573D7D6135aD) - issues CPCs to investors during ICO phases. 

## Token contract

CPC is [ERC-20](https://github.com/ethereum/EIPs/issues/20) standard token with the following paramaters:

- Name: **Cryptonia Poker Chips**
- Symbol: **CPC**
- Decimals: **2**
- Mintable: **Yes**, Special role 'minter', Finalizeable
- Burnable: **Yes**, owner can burn its tokens 
- RBAC: **Yes**, admin (can finalize, can add minters). Initially admin is contract deployer 0x8b2655f8940453d48de9a823402acbbda56c6289, admins can be added/deleted by admin. After deployment Crowdsale contract 0x2178456786133C163DfF480fEFfa7da3Dc251bFf was added as a minter. 
- Source Code: **[CryptoniaToken.sol](contracts/CryptoniaToken.sol)**
- Mainnet address: **[0x0809bD190C94F4408e691C410E67BFf0DF5d225d](https://etherscan.io/address/0x0809bD190C94F4408e691C410E67BFf0DF5d225d)**

## Crowdsale contract

- Phased: **Yes**, with specific price per phase
- Minimal Purchase: **0.1 ETH**
- Token amount based on: ETH value of Tx and exchange rate CPC per ETH (defined per each phase)
- RBAC: **Yes**, admin (can change phases and sink wallet, initially admin is 0x8b2655f8940453d48de9a823402acbbda56c6289)
- Collected ETH forwarded to: **sink wallet** account of the founder (initially 0x8b2655f8940453d48de9a823402acbbda56c6289, can be changed by admin)
- Sink wallet editable: **YES**, admin can change it over time to secure funds (initially admin is 0x8b2655f8940453d48de9a823402acbbda56c6289, can be added/deleted by admin)
- Source code: **[CryptoniaCrowdsale.sol](contracts/CryptoniaCrowdsale.sol)**
- Mainnet address: **[0x510093014fa8EE0cF957b591B581573D7D6135aD](https://etherscan.io/address/0x510093014fa8EE0cF957b591B581573D7D6135aD)**

Crowdsale for Cryptonia receives ethers and sends back corresponding amount of CPC tokens. 
Token price depends on the current phase (see the schedule).
The crowdsale contract contains a list of phases, each phase has a start time, end time and CPC per ETH exchange rate. 
If current time doesn't match any phase or transferred value less than minPurchase the operation is thrown (reverted).

### Crowdsale schedule
Shedule is initially constructed on the Crowdsale deployment on 2018-04-03. It can be changed at any time by addPhase/delPhase

| Phase | Start date (UTC)    | Start Unix | End date (UTC)      | End Unix   | Rate, CPC/ETH  |  
| ----- | ------------------- | ---------- | ------------------- | ---------- | -------------- |
| 0     | 2018-04-03 12:56:46 | 1522760206 | 2018-04-30 23:59:59 | 1525132799 |    11000.00    |
| 1     | 2018-05-01 00:00:00 | 1525132800 | 2018-05-31 23:59:59 | 1527811199 |     7000.00    |
| 2     | 2018-06-01 00:00:00 | 1527811200 | 2018-06-30 23:59:59 | 1530403199 |     5800.00    |

use [unixtimestamp.com](https://www.unixtimestamp.com/index.php) or unix date utility for conversion
from human to epoch
```
date -u -j -f "%Y-%m-%d  %H:%M:%S" "2018-04-10 00:00:00" "+%s"
```
from epoch to human
```
date -u -j -f "%s" "1530392399" "+%Y-%m-%d  %H:%M:%S"
```

### Crowdsale schedule modification

The internal phases schedule can be changed at any time by the owner with the following methods:
```
addPhase(_startDate, _endDate, _tokensPerETH)
delPhase(index)
```

## Wallets

All the funds received from the investors are forwarded to securely stored wallet (Externally Owned Account) 
to avoid any on-chain risks. Wallet can be changed at any point of time by the owner. 
```
Crowdsale.wallet()
Crowdsale.setWallet(address)
```

## Getting started
### Get the source code
Clone the contracts repository with submodules (we use zeppelin-solidity libraries)
```
git clone --recurse-submodules git@github.com:OnGridSystems/CryptoniaPokerContracts.git
```

### Test it
To be sure in code quality and compatibility we use truffle framowork for testing our code:

#### Run truffle tests
- Install [truffle framework](http://truffleframework.com) on your host. It will install solc-js compiler automatically.
- Run ```testrpc``` in one console and leave it open.
- Start the new console and type ```truffle test```.

### Deploy on the net

- Flatten your solidity code
The simplest way to move your code to the IDE and other tools is to make it flat (opposed to hierarchically organized files)
Install truffle-flattener via npm
```npm install -g truffle-flattener```
and flatten your crowdsale contract to a single code snippet, copy it
```truffle-flattener contracts/CryptoniaPokerCrowdsale.sol```
You can use [Remix IDE](http://remix.ethereum.org) for deployment on the net. 

- First deploy **Token** contract, you should get an address of deployed contract (*Token*)
```
deploy(Token)
```
As Tx get mined you should know Token address as a result.
- Deploy **Crowdsale** contract
```
deploy Crowdsale(wallet, Token)
```
where wallet is external address to receive depisited ethers, Token is the token contract deployed on previous step.

- Add/Del Phases
construct your schedule with following methods
```
Crowdsale.addPhase(_startDate, _endDate, _tokensPerETH)
Crowdsale.delPhase(index)
```
- Add Crowdsale contract to the minters of the token
```
Token.adminAddRole(Crowdsale.address,"minter")
```
### Post-Deploy steps
- Good practice is to verify Source Code on the etherscan. Do it for both Crowdsale and Token.
- Publish your Crowdsale contract for investors. 

### After crowdsale end
After the last phase ends you can disconnect Crowdsale from the token (remove minting privileges given before).
```
Token.adminDelRole(Crowdsale.address,"minter")
```

### Post-ICO state
* the token is still mintable. To continue minting you can grant minting permissions to
the new entity - extarnal account or contract.

## Authors
* OnGrid Systems: [Site](https://ongrid.pro), [GitHub](https://github.com/OnGridSystems/)