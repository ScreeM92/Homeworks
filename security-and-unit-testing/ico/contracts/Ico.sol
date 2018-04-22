pragma solidity 0.4.19;

import './Ownable.sol';
import './MemberLib.sol';

contract Ico is Ownable{
    using MemberLib for MemberLib.Members;
    MemberLib.Members members;
    
    uint256 initialTime;
    
    modifier CheckMemberToken(address user, uint256 tokens) {
        require(tokens > 0);
        require(members.membersData[user] > tokens);
        _;
    }
    modifier PresaleTime() {
        require((now - initialTime) <= 10 seconds);
        _;
    }
    modifier SaleTime() {
        uint256 time = now - initialTime;
        require((time > 10 seconds) && (time <= 30 seconds));
        _;
    }
    modifier TransferTime() {
        require((now - initialTime) > 30 seconds);
        _;
    }
    
    function Ico() public {
        initialTime = now;
    }
    
    function presale() public payable PresaleTime {
        require(msg.value / 1 ether > 0); //at least 1 ether
        require((msg.value / 1 ether) * 1 ether == msg.value); //accept only round ETH
        
        uint256 tokens = msg.value / 1 ether;
        members.buy(msg.sender, tokens);
    }
    
    function sale() public payable SaleTime {
        require(msg.value / 2 ether > 0); //at least 1 ether
        require((msg.value % 2 ether) == 0); //accept only round ETH
        
        uint256 tokens = (msg.value / 1 ether) / 2 ;
        members.buy(msg.sender, tokens);
    }
    
    function transfer(address to, uint256 tokens) public TransferTime CheckMemberToken(msg.sender, tokens) {
        uint256 prevOwnerTokens = members.membersData[msg.sender];
        uint256 prevToTokens = members.membersData[to];
        
        members.transfer(msg.sender, to, tokens);

        require(members.membersData[msg.sender] == (prevOwnerTokens - tokens));
        require(members.membersData[to] == (prevToTokens + tokens));
    }

    function getTokensCount() public view returns(uint256) {
        return(members.membersData[msg.sender]);
    }
}