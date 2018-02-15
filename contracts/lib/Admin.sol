pragma solidity ^0.4.18;

import "./Ownable.sol";
/**
 * @title Admin
 * @dev The Admin contract has an admin address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Admin is Ownable{
	address public admin;


	event AdminChanged(address indexed previousAdmin, address indexed newAdmin);


	/**
	 * @dev The Admin constructor sets the original `admin` of the contract to the sender
	 * account.
	 */
	function Admin() public {
		admin = msg.sender;
	}


	/**
	 * @dev Throws if called by any account other than the admin.
	 */
	modifier onlyAdmin() {
		require(msg.sender == admin);
		_;
	}


	/**
	 * @dev Allows the current admin to transfer control of the contract to a newAdmin.
	 * @param newAdmin The address to transfer adminship to.
	 */
	function setAdmin(address newAdmin) public onlyOwner {
		require(newAdmin != address(0));
		AdminChanged(admin, newAdmin);
		admin = newAdmin;
	}

}
