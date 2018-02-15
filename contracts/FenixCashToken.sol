pragma solidity ^0.4.18;

import "./lib/SafeMath.sol";
import "./lib/Ownable.sol";
import "./lib/Admin.sol";
import "./lib/StandardToken.sol";

contract FenixCashToken is StandardToken, Ownable, Admin {
	using SafeMath for uint256;

	string public constant name = "FENIX.CASH";
	string public constant symbol = "FENIX";
	uint256 public constant decimals = 18;

	uint256 constant INITIAL_SUPPLY = 432000000 * 1E18;

	event Spends(address indexed from, address indexed to, uint256 value);
	event Transmits(address indexed from, address indexed to, uint256 value);
	event Payments(address indexed from, address indexed to, uint256 value, uint256 commission);
	/**
	* @dev Constructor that gives msg.sender all of existing tokens.
	*/
	function FenixCashToken() public {
		totalSupply = INITIAL_SUPPLY;
		balances[msg.sender] = INITIAL_SUPPLY;
	}

	/**
	* @dev if ether is sent to this address, send it back.
	*/
	function () public {
		revert();
	}
	
	/**
	 * @dev Transmit tokens from one address to another
	 * @param _from address The address which you want to send tokens from
	 * @param _to address The address which you want to transfer to
	 * @param _value uint256 the amount of tokens to be transferred
	 */
	function transmit(address _from, address _to, uint256 _value) onlyOwner public returns (bool) {
		require(_to != address(0));
		require(_value <= balances[_from]);

		balances[_from] = balances[_from].sub(_value);
		balances[_to] = balances[_to].add(_value);
		Transmits(_from, _to, _value);
		return true;
	}

	/**
	* @dev Spend token for a specified address
	* @param _to The address to transfer to.
	* @param _value The amount to be transferred.
	*/
	function spend(address _to, uint256 _value) public returns (bool) {
		spendInternal(msg.sender, _to, _value);
		return true;
	}

	/**
	 * @dev Spend tokens from one address to another
	 * @param _from address The address which you want to send tokens from
	 * @param _to address The address which you want to transfer to
	 * @param _value uint256 the amount of tokens to be transferred
	 */
	function spendFrom(address _from, address _to, uint256 _value) onlyOwner public returns (bool) {
		spendInternal(_from, _to, _value);
		return true;
	}

	/**
	 * @dev Intrernal Common Spend method
	 * @param _from address The address which you want to send tokens from
	 * @param _to address The address which you want to transfer to
	 * @param _value uint256 the amount of tokens to be transferred
	 */
	function spendInternal(address _from, address _to, uint256 _value) internal returns (bool) {
		require(_to != address(0));
		require(_value <= balances[_from]);

		balances[_from] = balances[_from].sub(_value);
		balances[_to] = balances[_to].add(_value);
		Spends(_from, _to, _value);
		return true;
	}

	/**
	* @dev Pay token to a specified address
	* @param _to The address to transfer to.
	* @param _value The amount to be transferred.
	* @param _commission The amount to be transferred to Admin.
	*/
	function pay(address _to, uint256 _value, uint256 _commission) public returns (bool) {
		payInternal(msg.sender, _to, _value, _commission);
		return true;
	}

	/**
	 * @dev Pay tokens from one address to another
	 * @param _from address The address which you want to send tokens from
	 * @param _to address The address which you want to transfer to
	 * @param _value uint256 the amount of tokens to be transferred
	 * @param _commission uint256 the amount of tokens to be transferred to Admin
	 */
	function payFrom(address _from, address _to, uint256 _value, uint256 _commission) onlyOwner public returns (bool) {
		payInternal(_from, _to, _value, _commission);
		return true;
	}

	/**
	 * @dev Intrernal Common Pay Token method
	 * @param _from address The address which you want to send tokens from
	 * @param _to address The address which you want to transfer to
	 * @param _value uint256 the amount of tokens to be transferred
	 * @param _commission uint256 the amount of tokens to be transferred to Admin
	 */
	function payInternal(address _from, address _to, uint256 _value, uint256 _commission) internal returns (bool) {
		require(_to != address(0));
		require((_value + _commission) <= balances[_from]);

		balances[_from] = balances[_from].sub(_value).sub(_commission);
		balances[_to] = balances[_to].add(_value);
		balances[admin] = balances[admin].add(_commission);
		Payments(_from, _to, _value, _commission);
		return true;
	}
}