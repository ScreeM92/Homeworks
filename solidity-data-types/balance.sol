pragma solidity ^0.4.19;

contract Balance{
    address owner;
    address seller;
    address buyer;
    uint256 initTime;
    uint256 tokenCost;
    uint256 change;
    uint256 funderCouns;

    struct Funder {
        address addr;
        uint amount;
        bool isHold;
    }
    
    mapping (address => Funder) funders;
    
    event BuyEvent(address indexed from, uint amount);
    event WithdrawnEvent(address indexed to, uint amountWithdrawn);
    
    modifier onlyOwner {
        require(owner == msg.sender);
        _;
    }
    
    modifier sendAmount(uint256 amount) {
        require(amount >= 1 ether);
        _;
    }
    
    modifier timeLimitBuy {
        require(block.timestamp - initTime <= 5 minutes );
        _;
    }
    
    modifier timeLimitWithdrawn {
        require(block.timestamp - initTime >= 1 years );
        _;
    }
    
    modifier timeLimitSend {
        require(block.timestamp - initTime > 5 minutes );
        _;
    }
    
    function Balance() public{
        owner=msg.sender;
        initTime = block.timestamp;
        
        tokenCost = 5;
    }
    
    function buy() public payable timeLimitBuy sendAmount(msg.value) {
        uint256 amountPayed = msg.value;
        buyer = msg.sender;
        
        Funder storage fund = funders[buyer];
        require(fund.amount == 0);
        
        if(amountPayed > 1 ether) {
            change = amountPayed - 1 ether;
            buyer.transfer(change);
            
            assert(amountPayed == change + 1 ether);
        }
        
        funders[buyer] = Funder({ addr: buyer, amount: tokenCost, isHold: true });
        BuyEvent(buyer, amountPayed);
    }
    
    function Withdraw (uint256 amount) onlyOwner timeLimitWithdrawn public {
        uint256 currentBalance = this.balance;
        require(amount <= this.balance);

        owner.transfer(amount);
        assert(this.balance == currentBalance - amount);
        
        WithdrawnEvent(owner, amount);
    }
    
    function Send (address to, uint256 amount) timeLimitSend public {
        seller = msg.sender;
        
        Funder storage fundSeller = funders[seller];
        require(fundSeller.amount >= amount);
        
        Funder storage fundTo = funders[to];
        if(fundTo.amount > 0) {
            fundTo.amount += amount;
        } 
        else {
            funders[to] = Funder({ addr: to, amount: amount, isHold: true });
        }
        
        funders[seller].amount -= amount;
        if(fundSeller.amount == 0) {
            funders[seller].isHold = false;
        }
    }
    
    function checkTokenCount() public view returns (uint) {
        Funder storage fund = funders[msg.sender];
        return fund.amount;
    }
    
    function getBalance() onlyOwner public view returns (uint) {
        return this.balance;
    }
} 