//this function will be called when the whole page is loaded
$(function() {
	var contractInstance,
		abi = [{"constant":true,"inputs":[{"name":"person","type":"address"}],"name":"getPokemonsByPerson","outputs":[{"name":"","type":"uint8[]"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"pokemon","type":"uint8"}],"name":"getPokemonHolders","outputs":[{"name":"","type":"address[]"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"pokemon","type":"uint8"}],"name":"catchPokemon","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"anonymous":false,"inputs":[{"indexed":true,"name":"by","type":"address"},{"indexed":true,"name":"pokemon","type":"uint8"}],"name":"LogPokemonCaught","type":"event"}],
		address = "0x8cdaf0cd259887258bc13a92c0a6da92698644c0",
		acc,
		pokemons = ["Bulbasaur", "Ivysaur", "Venusaur", "Charmander", "Charmeleon", "Charizard", "Squirtle", "Wartortle",
	    "Blastoise", "Caterpie", "Metapod", "Butterfree", "Weedle", "Kakuna", "Beedrill", "Pidgey", "Pidgeotto", "Pidgeot", "Rattata", "Raticate",
	    "Spearow", "Fearow", "Ekans", "Arbok", "Pikachu", "Raichu", "Sandshrew", "Sandslash", "NidoranF", "Nidorina", "Nidoqueen", "NidoranM"];

    if (typeof web3 === 'undefined') {
		//if there is no web3 variable
		displayMessage("Error! Are you sure that you are using metamask?");
	} else {
		displayMessage("Welcome to our DAPP!");
		init();
	}

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
		$('#message').text(message);
	}

	$('#btn-submit').on('click', function() {
		updateAccount();
		var input = $('#input').val()

		if(Number.isInteger(parseInt(input))) {
			contractInstance.catchPokemon(input, {"from": acc}, function(err, res){
				if(!err){
					swal("Good job!", "Successfully catched pokemon!", "success");
				} else {
					swal("Unsuccessfully catched pokemon!", "Please try again later!", "error");
				}
			});
		} else {
			swal("Wrong input!", "Please try again!", "error");
		}
	});

	$('#btn-read').on('click', function() {
		updateAccount();	
		var input = $('#input').val()

		if(input.length == 42) {
			contractInstance.getPokemonsByPerson(input, {"from": acc}, function(err, res) {
				if(!err){
					var result = 'The person haven\'t caught any pokemons!';
					if(res.length > 0) {
						const catchPokemons = res.map(x => pokemons[x]);
						result = 'The person have caught: ' + catchPokemons.join(', ');
					}			

					swal("Good job!", "Successfully got pokemons by person! " + result, "success");
				} else {
					swal("Unsuccessfully got pokemons by person!", "Please try again later!", "error");
				}
			});
		} else if(Number.isInteger(parseInt(input))) {
			if(!pokemons[input]) {
				swal("The pokemon is missing!", "Please try with other one!", "error");
				return;
			}
			contractInstance.getPokemonHolders(input, {"from": acc}, function(err, res) {
				if(!err){
					var result = pokemons[input] + ' hasn\'t caught by any person!';
					if(res.length > 0) {
						result = 'The holders that have caught ' + pokemons[input] + ': ' + res.join(', ');
					}			

					swal("Good job!", "Successfully got pokemon's holders! " + result, "success");
				} else {
					swal("Unsuccessfully got pokemon's holders!", "Please try with other one pokemon index!", "error");
				}
			});
		} else {
			swal("Wrong input!", "Please try again!", "error");
		}
	});
});

