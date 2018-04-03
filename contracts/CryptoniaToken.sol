pragma solidity ^0.4.21;


import "../zeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import "../zeppelin-solidity/contracts/ownership/rbac/RBAC.sol";


/**
 * @title Cryptonia Poker Chips Contract
 * @author Kirill Varlamov (@ongrid), OnGrid systems
 * @dev ERC-20 compatible token with zeppelin's RBAC
 */
contract CryptoniaToken is StandardToken, RBAC {
  string public name = "Cryptonia Poker Chips";
  string public symbol = "CPC";
  uint8 public decimals = 2;
  uint256 public cap = 100000000000;
  bool public mintingFinished = false;
  string constant ROLE_MINTER = "minter";

  event Mint(address indexed to, uint256 amount);
  event MintFinished();
  event Burn(address indexed burner, uint256 value);

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyRole(ROLE_MINTER) public returns (bool) {
    require(!mintingFinished);
    require(totalSupply_.add(_amount) <= cap);
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyAdmin public returns (bool) {
    require(!mintingFinished);
    mintingFinished = true;
    emit MintFinished();
    return true;
  }

  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint256 _value) public {
    require(_value <= balances[msg.sender]);
    // no need to require value <= totalSupply, since that would imply the
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure

    address burner = msg.sender;
    balances[burner] = balances[burner].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(burner, _value);
    emit Transfer(burner, address(0), _value);
  }
}
