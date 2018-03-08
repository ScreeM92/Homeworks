//this function will be called when the whole page is loaded
window.onload = function(){
	if (typeof web3 === 'undefined') {
		//if there is no web3 variable
		displayMessage("Error! Are you sure that you are using metamask?");
	} else {
		displayMessage("Welcome to our DAPP!");
		init();
	}
}

var contractInstance;

var abi = [{"constant":false,"inputs":[{"name":"incrementBy","type":"uint256"}],"name":"count","outputs":[{"name":"","type":"uint256"},{"name":"","type":"uint256"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"getCounter","outputs":[{"name":"","type":"uint256"},{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"anonymous":false,"inputs":[{"indexed":true,"name":"previousOwner","type":"address"},{"indexed":true,"name":"newOwner","type":"address"}],"name":"OwnershipTransferred","type":"event"}];

var address = "0x8cdaf0cd259887258bc13a92c0a6da92698644c0";
var acc;

function init(){
	var Contract = web3.eth.contract(abi);
	contractInstance = Contract.at(address);
	updateAccount();
}

function updateAccount(){
	//in metamask, the accounts array is of size 1 and only contains the currently selected account. The user can select a different account and so we need to update our account variable
	acc = web3.eth.accounts[0];
}

function displayMessage(message){
	var el = document.getElementById("message");
	el.innerHTML = message;
}

function getTextInput(){
	var el = document.getElementById("input");
	
	return el.value;
}

function onButtonPressed(){
	updateAccount();

	var input = getTextInput();

	contractInstance.count(input, {"from": acc}, function(err, res){
		if(!err){
			displayMessage("Successfully incremented value!");
		} else {
			displayMessage("Something went wrong. Are you sure that you are the current owner?");
		}
	});
}

function onSecondButtonPressed(){
	updateAccount();	

	contractInstance.getCounter.call({"from": acc}, function(err, res) {
		if(!err){
			displayMessage("Successfully got value! The value is " + res[1].valueOf() + ' and it is for ' + res[0].valueOf() + ' times changed!');
		} else {
			displayMessage("Something went horribly wrong. Deal with it:", err);
		}
	});
}
