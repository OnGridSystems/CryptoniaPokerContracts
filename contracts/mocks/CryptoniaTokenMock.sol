pragma solidity ^0.4.18;


import "../CryptoniaToken.sol";


// mock class using BasicToken
contract CryptoniaTokenMock is CryptoniaToken {

  function CryptoniaTokenMock(address initialAccount, uint256 initialBalance) public {
    balances[initialAccount] = initialBalance;
    totalSupply_ = initialBalance;
  }

}
