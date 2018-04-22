pragma solidity ^0.4.19;


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
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

library MemberLib {
    event DonateEvent(address indexed owner, uint256 value);
    event AddMemberEvent(address indexed owner);
    
    struct Member {
        uint joinedAt;
        uint fundsDonated;
    }
    struct Members { mapping(address => Member) membersData; }
    
    function add(Members storage self, address adr) public {
        emit AddMemberEvent(adr);
        self.membersData[adr] = Member({ joinedAt: now, fundsDonated: 0});
    }
    
    function donated(Members storage self, address adr, uint value) public {
        emit DonateEvent(adr, value);
        self.membersData[adr].fundsDonated += value;
    }
}

contract Member is Ownable{
    using MemberLib for MemberLib.Members;
    MemberLib.Members members;
    mapping(address => bool) isMember;
    
    modifier onlyMember(address memb) {
        require(isMember[memb]);
        _;
    }
    
    function addMember(address adr) public onlyOwner {
        members.add(adr);
        isMember[adr] = true;
    }
    
    function donate() public onlyMember(msg.sender) payable {
        require(msg.value > 0);
        
        members.donated(msg.sender, msg.value);
    }
}