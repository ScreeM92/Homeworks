pragma solidity 0.4.19;

import './SafeMath.sol';

library MemberLib {
    using SafeMath for uint256;
    
    event LogBuyToken(address indexed owner, uint256 value);
    event LogTransferToken(address indexed owner, address indexed newOwner, uint256 value);
    
    struct Members { mapping(address => uint) membersData; }
    
    function buy(Members storage self, address adr, uint256 value) public {
        LogBuyToken(adr, value);
        self.membersData[adr] = SafeMath.add(self.membersData[adr], value);
    }
    
    function transfer(Members storage self, address ownerAdr, address to, uint256 value) public {
        LogTransferToken(ownerAdr, to, value);
        self.membersData[ownerAdr] = SafeMath.sub(self.membersData[ownerAdr], value);
        self.membersData[to] = SafeMath.add(self.membersData[to], value);
    }
}