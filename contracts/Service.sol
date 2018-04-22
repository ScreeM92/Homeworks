pragma solidity ^0.4.19;

contract Service{
    address owner;
    address seller;
    uint servicesCost;
    uint amountPayedForTheService;
    uint balanceBeforeWithdraw;
    uint change;
    uint lastTransactionTime;
    uint lastWithdrawnAt;
    
    event Confirms(address indexed from, uint amount);
    event Withdrawn(address indexed to, uint amountWithdrawn);
    
    modifier isAmountEnoughToBuy(uint sendAmount) {
        require(sendAmount>=servicesCost);
        _;
    }
    modifier timeLimitTransaction(uint _minutes) {
        require(now - lastTransactionTime >= _minutes );
        _;
    }
    modifier timeLimitWithdrawn(uint _minutes) {
        require(now - lastWithdrawnAt >= _minutes );
        _;
    }
    modifier onlyOwner {
        require(owner == msg.sender);
        _;
    }
    
    function Service() public{
        owner=msg.sender;
        servicesCost=1 ether;
        lastTransactionTime=0;
        lastWithdrawnAt=0;
    }
    function BuyService () timeLimitTransaction(2 minutes) isAmountEnoughToBuy(msg.value) public payable {
        seller=msg.sender;
        amountPayedForTheService=msg.value;
        change = amountPayedForTheService - servicesCost;
        lastTransactionTime=now;
        if (change>0){
            seller.transfer(change);
        }
        assert(amountPayedForTheService == change + servicesCost);
        Confirms(seller,amountPayedForTheService);
    }
    function Withdraw (uint _amount) onlyOwner timeLimitWithdrawn(1 hours) public {
        balanceBeforeWithdraw=this.balance;
        require(_amount <= this.balance);
        require(_amount <= 5000000000000000000);
        lastWithdrawnAt=now;
        owner.transfer(_amount);
        assert(this.balance == balanceBeforeWithdraw - _amount);
        
        Withdrawn(owner, _amount);
    }
    
    function getBalance() public view returns (uint) {
        return this.balance;
    }
} 