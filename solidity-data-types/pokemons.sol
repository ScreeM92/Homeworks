pragma solidity ^0.4.19;

contract Pokemon {
    address owner;
    enum Pokemons { Bulbasaur, Ivysaur, Squirtle, Butterfree, Weedle, Beedrill, Pikachu, Sandshrew, Egg, Nidoran } Pokemons pokemons;
    
    struct Person {
        uint8[10] pokemons;
        uint256 lastCatch;
    }
    
    mapping (address => Person) private people;
    address[][10] private possessors;
    
    function Pokemon() public {
        owner = msg.sender;
    }
    
    function catchPokemon(Pokemons pokemon) public {
        Person storage person = people[msg.sender];
        
        require((block.timestamp - person.lastCatch) > 15 seconds);
        
        uint8 index = uint8(pokemon);
        require(person.pokemons[index] == 0);
        
        person.pokemons[index] = 1;
        possessors[index].push(msg.sender);
        person.lastCatch = block.timestamp;
    }
    
    function getMyPokomons() view public returns(uint8[10]) {
        Person storage person = people[msg.sender];
        
        return person.pokemons;
    }
    
    function getPokemonPossessors(Pokemons pokemon) view public returns(address[]){
        uint8 index = uint8(pokemon);
        return possessors[index];
    }
}