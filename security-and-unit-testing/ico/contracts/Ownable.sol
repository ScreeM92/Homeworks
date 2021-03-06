pragma solidity 0.4.19;

contract Ownable {
    address public owner;
    
    event LogOwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    function Ownable() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        LogOwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}