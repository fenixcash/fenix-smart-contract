pragma solidity ^0.4.18;

import "./lib/SafeMath.sol";
import "./lib/Ownable.sol";
import "./FenixCashToken.sol";

/**
* @title FenixCashTokenIco
* @dev Very simple ICO Token
*/
contract FenixCashTokenPreSale is Ownable {
	using SafeMath for uint256;

	// The token being sold
	FenixCashToken public token;

	// address where funds are collected
	address public wallet;

	// how many token units a buyer gets per QTUM
	uint256 public rate = 0.005 * 1E8;

	// amount of token sold so far
	uint256 public sold;

	// amount of token to be sold on ICO
	uint256 public goal = 7200000 * 1E18;

	// amount of raised money in uqtum
	uint256 public uqtumRaised;

	// contributors for money 
	mapping(address => uint256) public uqtumRaiser;

	bool internal isKilled = false;

	// events for logging
	event WalletChange(address _wallet, uint256 _timestamp);
	event TokenPurchase(address indexed _purchaser, address indexed _beneficiary, uint256 _value, uint256 _amount, uint256 _timestamp);
	event TransferManual(address indexed _from, address indexed _to, uint256 _value, string _message);

	// timestamps for ICO phases
	uint256 public constant PHASES_START = 1519171200;
	uint256 public constant PHASES_END = 1520380799;

	/**
	* @dev Constructor that gives msg.sender all of existing tokens.
	*/
	function FenixCashTokenPreSale(address _token , address _wallet) public {
		// set token
		token = FenixCashToken(_token);

		// set wallet 
		wallet = _wallet;
	}

	// Wallet functions	
	function setWallet(address _wallet) onlyOwner public returns(bool) {
		wallet = _wallet;
		WalletChange(_wallet , now);
		return true;
	}

	// calculate token sale
	function calculateTokens(uint256 value) public constant returns (uint256) {
		// calculate tokens
		uint256 amount = value.mul(1E18).div(rate);
		return amount;
	}	

	// is valid purchase 
	function isValidPurchase(uint256 value, uint256 amount) internal constant returns (bool) {
		bool validPeriod = PHASES_START <= now && now <= PHASES_END;
		bool validValue = value != 0;
		bool validRate = rate > 0;
		bool validAmount = goal.sub(sold) >= amount;

		return validPeriod && validValue && validRate && validAmount && !isKilled;
	}

	// payable method
	function() public payable {
        buyTokens(msg.sender);
    }

	// low level token purchase function
	function buyTokens(address beneficiary) public payable {
		require(beneficiary != address(0));

		// calculate token amount to be created
		uint256 value = msg.value;
		uint256 amount = calculateTokens(value);
		require(isValidPurchase(value , amount));

		// update state
		sold = sold.add(amount);
		uqtumRaised = uqtumRaised.add(value);
		uqtumRaiser[msg.sender] = uqtumRaiser[msg.sender].add(value);

		// transfer tokens from contract balance
		token.transfer(beneficiary, amount);
		TokenPurchase(msg.sender, beneficiary, value, amount, now);
	}

	/**
	* @dev transmit token for a specified address
	* @param _to The address to transmit to.
	* @param _value The amount to be transferred.
	* @param _message message to log after transfer.
	*/
	function transferManual(address _to, uint256 _value, string _message) onlyOwner public returns (bool) {
		require(_to != address(0));

		// transfer tokens manually from contract balance
		token.transfer(_to , _value);
		TransferManual(msg.sender, _to, _value, _message);
		return true;
	}

	/**
	* @dev withdraw funds to wallet
	*/
	function withdraw() onlyOwner public payable {
		wallet.transfer(this.balance);
	}	

	/**
	* @dev kill contract and return funds to owner.
	*/	
	function kill() onlyOwner public {
		// burn all tokens
		var tokens = token.balanceOf(this); 
		token.transfer(owner, tokens);

		isKilled = true;
	}
}
