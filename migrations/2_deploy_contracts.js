var FenixCashToken = artifacts.require("./FenixCashToken.sol");
var FenixCashTokenPreSale = artifacts.require("./FenixCashTokenPreSale.sol");
var FenixCashTokenSale = artifacts.require("./FenixCashTokenSale.sol");

module.exports = function(deployer , network , accounts) {
	var owner = accounts[0];

	deployer.deploy(FenixCashToken).then(function(){
		FenixCashToken.deployed().then(async function(tokenInstance) {
			console.log('Token Address : ' + tokenInstance.address);

			deployer.deploy(FenixCashTokenPreSale , tokenInstance.address , owner).then(function(){
				FenixCashTokenSale.deployed().then(async function(presaleInstance) {
					console.log('Token Pre Sale Address : ' + presaleInstance.address);
				});
			});	

			deployer.deploy(FenixCashTokenSale , tokenInstance.address , owner).then(function(){
				FenixCashTokenSale.deployed().then(async function(saleInstance) {
					console.log('Token Sale Address : ' + saleInstance.address);
				});
			});		
		});	
	});
};