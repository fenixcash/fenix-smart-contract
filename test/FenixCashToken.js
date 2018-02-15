'use strict';
var assert_throw = require('./helpers/utils').assert_throw;
const assertRevert = require('./helpers/assertRevert');
var FenixCashToken = artifacts.require('./FenixCashToken.sol');

const promisify = (inner) =>
	new Promise((resolve, reject) =>
		inner((err, res) => {
			if (err) { reject(err) }
			resolve(res);
		})
);

const getBalance = (account, at) => promisify(cb => web3.eth.getBalance(account, at, cb));
		
var tokenInstance;
var saleInstance;

var owner;

contract('FenixCashToken' , (accounts) => {
	owner = accounts[0];

	beforeEach(async () => {
		tokenInstance = await FenixCashToken.new({from: owner});
	});

	it('should match name' , async () => {
		var name = await tokenInstance.name.call();
		assert.equal(name , 'FENIX CASH' , 'name does not match');		
	});

	it('should match symbol' , async () => {
		var symbol = await tokenInstance.symbol.call();
		assert.equal(symbol , 'FENIX.CASH' , 'symbol does not match');		
	});

	it('should match decimals' , async () => {
		var decimals = await tokenInstance.decimals.call();
		assert.equal(decimals , 18 , 'decimals does not match');		
	});

	it('owner should have full balance' , async () => {
		var balance = await tokenInstance.balanceOf.call(owner);
		assert.equal(balance.toNumber(), 432000000 * 1E18 , 'owner balance does not match');
	});

	it('should throw an error when trying to transfer more than balance', async () => {
		var balance = await tokenInstance.balanceOf.call(owner);
		assert_throw(tokenInstance.transfer(accounts[1], (balance + 1)));
	});

	it('should throw an error when trying to transfer to 0x0', async () => {
		assert_throw(tokenInstance.transfer(0x0, 100));
	});

	it('should prevent non-owners from transfering', async () => {
		var other = accounts[2];
		var owner = await tokenInstance.owner.call();
		assert.isTrue(owner !== other);
		assert_throw(tokenInstance.transferOwnership(other, {from: other}));
	});

	it('should have an owner', async () => {
		tokenInstance = await FenixCashToken.new({from: owner});
		owner = await tokenInstance.owner();
		assert.isTrue(owner !== 0);
	});

	it('changes owner after transfer', async () => {
		var other = accounts[1];
		await tokenInstance.transferOwnership(other);
		var owner = await tokenInstance.owner();
		assert.isTrue(owner === other);
	});

	it('should guard ownership against stuck state', async () => {
		var originalOwner = await tokenInstance.owner();
		assert_throw(tokenInstance.transferOwnership(null, {from: originalOwner}));
	});

	it('should transfer tokens from owner and return back' , async () => {
		var account1 = owner;
		var account2 = accounts[1];
		var unit = 10E18;

		var balanceBeforeSender = await tokenInstance.balanceOf.call(account1);
		var balanceBeforeReceiver = await tokenInstance.balanceOf.call(account2);

		await tokenInstance.transfer(account2 , unit , {from: account1});

		var balanceAfterSender = await tokenInstance.balanceOf.call(account1);
		var balanceAfterReceiver = await tokenInstance.balanceOf.call(account2);		

		assert.equal(balanceBeforeSender.toNumber() , balanceAfterSender.toNumber() + unit , 'sender balance should be decreased');
		assert.equal(balanceBeforeReceiver.toNumber() , balanceAfterReceiver.toNumber() - unit , 'receiver balance should be increased');

		// var account1 = accounts[1];
		// var account2 = owner;

		// var balanceBeforeSender = await tokenInstance.balanceOf.call(account1);
		// var balanceBeforeReceiver = await tokenInstance.balanceOf.call(account2);

		// await tokenInstance.transferOwnership(account1);

		// await tokenInstance.transfer(account2 , unit , {from: account1});

		// var balanceAfterSender = await tokenInstance.balanceOf.call(account1);
		// var balanceAfterReceiver = await tokenInstance.balanceOf.call(account2);		

		// assert.equal(balanceBeforeSender.toNumber() , balanceAfterSender.toNumber() + unit , 'sender balance should be decreased');
		// assert.equal(balanceBeforeReceiver.toNumber() , balanceAfterReceiver.toNumber() - unit , 'receiver balance should be increased');
	});

});