# Example watchdog script for Cryptonia contracts
Gets and prints out state variables of Token and Crowdsale contracts

## Installation
tested on Ubuntu 16.04 LTS xenial)

### Update linux packages and install latest python

```
apt -y update
apt -y install software-properties-common
add-apt-repository -y ppa:deadsnakes/ppa
apt -y update
apt -y upgrade
apt -y install screen vim python3.6-dev python3-pip python3.6 git
```

install virtualenv PIP-way
```
pip3 install -U pip virtualenv
```

### Python virtualenv
Create and activate venv, install dependencies
```
virtualenv --python=python3.6 .
source bin/activate
pip install -r requirements.txt
```

## Run
```
./watchdog.py
Token Total Supply: 539100
Crowdsale weiRaised: 490000000000000000
Crowdsale CurrentPhaseIndex: 0
Crowdsale CurrentPhase: [1522760206, 1525132799, 1100000, 539000]
```
The contract variables are printed to console

## Authors
* OnGrid Systems: [Site](https://ongrid.pro), [GitHub](https://github.com/OnGridSystems/)
