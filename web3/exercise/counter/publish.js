var Web3 = require("web3");
var web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:9545"));

var acc = web3.eth.accounts[0]; //get the first account

//Code:
/*
pragma solidity 0.4.20;

contract Ownable {
    address public owner;
    
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    function Ownable() public {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract Counter is Ownable {
    uint times = 0;
    uint value = 0;
    
    function count(uint incrementBy) public onlyOwner returns (uint, uint){
        value += incrementBy;
        times ++;
        
        return (times, value);
    }
    
    function getCounter() public view returns (uint, uint) {
        return (times, value);
    }
}
*/

//Store this contract's compiled bytecode and ABI
var abi = [{"constant":false,"inputs":[{"name":"incrementBy","type":"uint256"}],"name":"count","outputs":[{"name":"","type":"uint256"},{"name":"","type":"uint256"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"getCounter","outputs":[{"name":"","type":"uint256"},{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"anonymous":false,"inputs":[{"indexed":true,"name":"previousOwner","type":"address"},{"indexed":true,"name":"newOwner","type":"address"}],"name":"OwnershipTransferred","type":"event"}];
var bytecode = "606060405260006001556000600255336000806101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055506103a98061005d6000396000f300606060405260043610610062576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680633b3546c8146100675780638ada066e146100a55780638da5cb5b146100d5578063f2fde38b1461012a575b600080fd5b341561007257600080fd5b6100886004808035906020019091905050610163565b604051808381526020018281526020019250505060405180910390f35b34156100b057600080fd5b6100b86101f2565b604051808381526020018281526020019250505060405180910390f35b34156100e057600080fd5b6100e8610203565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b341561013557600080fd5b610161600480803573ffffffffffffffffffffffffffffffffffffffff16906020019091905050610228565b005b6000806000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff161415156101c157600080fd5b8260026000828254019250508190555060016000815480929190600101919050555060015460025491509150915091565b600080600154600254915091509091565b6000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b6000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff1614151561028357600080fd5b600073ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff16141515156102bf57600080fd5b8073ffffffffffffffffffffffffffffffffffffffff166000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff167f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e060405160405180910390a3806000806101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff160217905550505600a165627a7a72305820e0879e6c47668a858550996770eb4490f544d7b8466690f8a4fd87e85e2d2c590029"

//create the contract instance. We can use this instance to publish or connect to a published contract
var Contract = web3.eth.contract(abi);

//create a JS Object (key-value pairs), holding the data we need to publish our contract
var publishData = {
	"from": acc, //the account from which it will be published
	"data": bytecode,
	"gas": 4000000 //gas limit. This should be the same or lower than Ethereum's gas limit
}

//publish the contract, passing a callback that will be called twice. Once when the transaction is sent, and once when it is mined
//the first argument is the constructor argument
Contract.new(publishData, function(err, contractInstance) {
	if(!err) {
		if(contractInstance.address) { //if the contract has an address aka if the transaction is mined
			console.log("New contract address is :", contractInstance.address);
		}
	} else {
		console.error(err); //something went wrong
	}
});
