pragma solidity 0.4.21;

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

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

library MemberLib {
    using SafeMath for uint256;
    
    event BuyTokenEvent(address indexed owner, uint256 value);
    event TransferTokenEvent(address indexed owner, address indexed newOwner, uint256 value);
    
    struct Members { mapping(address => uint) membersData; }
    
    function buy(Members storage self, address adr, uint256 value) public {
        emit BuyTokenEvent(adr, value);
        self.membersData[adr] = SafeMath.add(self.membersData[adr], value);
    }
    
    function transfer(Members storage self, address ownerAdr, address to, uint256 value) public {
        emit TransferTokenEvent(ownerAdr, to, value);
        self.membersData[ownerAdr] = SafeMath.sub(self.membersData[ownerAdr], value);
        self.membersData[to] = SafeMath.add(self.membersData[to], value);
    }
}

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
        uint256 aa = msg.value;
        uint256 tokens = aa / 1 ether;
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