pragma solidity ^0.4.21;

import "../zeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "../zeppelin-solidity/contracts/math/SafeMath.sol";
import "../zeppelin-solidity/contracts/ownership/rbac/RBAC.sol";
import "./CryptoniaToken.sol";


/**
 * @title Crowdsale Contract
 * @author Kirill Varlamov (@ongrid), OnGrid systems
 * @dev Crowdsale is a contract for managing a token crowdsale,
 * allowing investors to purchase tokens with ether.
 */
contract CryptoniaCrowdsale is RBAC {
  using SafeMath for uint256;

  struct Phase {
    uint256 startDate;
    uint256 endDate;
    uint256 tokensPerETH;
    uint256 tokensIssued;
  }

  Phase[] public phases;

  // The token being sold
  CryptoniaToken public token;

  // Address where funds get collected
  address public wallet;

  // Amount of ETH raised in wei. 1 wei is 10e-18 ETH
  uint256 public weiRaised;

  // Amount of tokens issued by this contract
  uint256 public tokensIssued;

  /**
   * Event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  /**
   * @dev Events for contract states changes
   */
  event PhaseAdded(address indexed sender, uint256 index, uint256 startDate, uint256 endDate, uint256 tokensPerETH);
  event PhaseDeleted(address indexed sender, uint256 index);
  event WalletChanged(address newWallet);
  event OracleChanged(address newOracle);

  /**
   * @param _wallet Address where collected funds will be forwarded to
   * @param _token  Address of the token being sold
   */
  function CryptoniaCrowdsale(address _wallet, CryptoniaToken _token) public {
    require(_wallet != address(0));
    require(_token != address(0));
    wallet = _wallet;
    token = _token;
  }

  /**
   * @dev fallback function receiving investor's ethers
   *      It calculates deposit USD value and corresponding token amount,
   *      runs some checks (if phase cap not exceeded, value and addresses are not null),
   *      then mints corresponding amount of tokens, increments state variables.
   *      After tokens issued Ethers get transferred to the wallet.
   */
  function() external payable {
    uint256 weiAmount = msg.value;
    address beneficiary = msg.sender;
    uint256 currentPhaseIndex = getCurrentPhaseIndex();
    uint256 tokens = weiAmount.mul(phases[currentPhaseIndex].tokensPerETH).div(1 ether);
    require(beneficiary != address(0));
    require(weiAmount != 0);
    weiRaised = weiRaised.add(weiAmount);
    phases[currentPhaseIndex].tokensIssued = phases[currentPhaseIndex].tokensIssued.add(tokens);
    tokensIssued = tokensIssued.add(tokens);
    token.mint(beneficiary, tokens);
    wallet.transfer(msg.value);
    emit TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
  }

  /**
   * @dev Checks if dates overlap with existing phases of the contract.
   * @param _startDate  Start date of the phase
   * @param _endDate    End date of the phase
   * @return true if provided dates valid
   */
  function validatePhaseDates(uint256 _startDate, uint256 _endDate) view public returns (bool) {
    if (_endDate <= _startDate) {
      return false;
    }
    for (uint i = 0; i < phases.length; i++) {
      if (_startDate >= phases[i].startDate && _startDate <= phases[i].endDate) {
        return false;
      }
      if (_endDate >= phases[i].startDate && _endDate <= phases[i].endDate) {
        return false;
      }
    }
    return true;
  }

  /**
   * @dev Adds a new phase
   * @param _startDate  Start date of the phase
   * @param _endDate    End date of the phase
   * @param _tokensPerETH  amount of tokens per ETH
   */
  function addPhase(uint256 _startDate, uint256 _endDate, uint256 _tokensPerETH) public onlyAdmin {
    require(validatePhaseDates(_startDate, _endDate));
    require(_tokensPerETH > 0);
    phases.push(Phase(_startDate, _endDate, _tokensPerETH, 0));
    uint256 index = phases.length - 1;
    emit PhaseAdded(msg.sender, index, _startDate, _endDate, _tokensPerETH);
  }

  /**
   * @dev Delete phase by its index
   * @param index Index of the phase
   */
  function delPhase(uint256 index) public onlyAdmin {
    require (index < phases.length);

    for (uint i = index; i < phases.length - 1; i++) {
      phases[i] = phases[i + 1];
    }
    phases.length--;
    emit PhaseDeleted(msg.sender, index);
  }

  /**
   * @dev Return current phase index
   * @return current phase id
   */
  function getCurrentPhaseIndex() view public returns (uint256) {
    for (uint i = 0; i < phases.length; i++) {
      if (phases[i].startDate <= now && now <= phases[i].endDate) {
        return i;
      }
    }
    revert();
  }

  /**
   * @dev Set new wallet to collect ethers
   * @param _newWallet EOA or the contract adderess of the new receiver
   */
  function setWallet(address _newWallet) onlyAdmin public {
    require(_newWallet != address(0));
    wallet = _newWallet;
    emit WalletChanged(_newWallet);
  }
}
