pragma solidity ^0.4.19;

//provides basic authorization control functions
contract Ownable {
    address public owner;
    
    function Ownable() public {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        //there is no case where this function can overflow/underflow
        uint256 c = a / b;
        return c;
    }
    
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

library MemberLib {
    struct Member {
        address addr;
        uint256 amount;
        uint256 lastTime;
        uint256 lastAmount;
    }
    
    function addMember(Member storage self, address to) public {
        self.addr = to;
        self.lastTime = now;
    }
}

contract MemberVoter is Ownable {
    uint256 countMembers;
    using MemberLib for MemberLib.Member;
    using SafeMath for uint;
    
    mapping(bytes32 => Vote) voting;
    mapping(address => MemberLib.Member) public members;
    
    struct Vote {
        mapping (address => bool) voted;
        address addrTo;
        uint256 count;
    }
    
    modifier canAddMember(address addr) {
        require(addr != 0); //the address should exist
        require(members[addr].addr == 0); //member shouldn't nexist
        _;
    }
    
    modifier onlyMember() {
        require(members[msg.sender].addr != 0); //member shouldn't exist
        _;
    }
    
    event AddMemberEvent(address indexed addr, uint256 time);
    
    function MemberVoter() public {
        countMembers = 0;
        _addMember(owner);
    }
    
    function _addMember(address addr) canAddMember(addr) private {
        assert(members[addr].addr == 0);
        
        members[addr].addMember(addr);
        countMembers++;
        
        AddMemberEvent(addr, now);
    }
    
    function vote(address to) onlyMember public {
        assert(to != msg.sender);
        
        bytes32 id = keccak256(msg.sender, to);
        
        if(members[to].addr == 0) {
            voting[id] = Vote ({
                addrTo: to,
                count: 1
            }); 
            
            voting[id].voted[msg.sender] = true;
        } 
        else
        {
            assert(!voting[id].voted[msg.sender]);
            
            voting[id].count++;
        }
    }
    
    function kill() onlyOwner public {
        selfdestruct(this);
    }
}
