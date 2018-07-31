
var Bank = artifacts.require("Bank"); //This is for successfuly deploy contract
//and for call Bank.json
module.exports = function(deployer) {
  // Use deployer to state migration tasks.
	let ownerAddress = web3.eth.accounts[0];
	//web3.eth.account contains array of client's name
	deployer.deploy(Bank,ownerAddress);




};
