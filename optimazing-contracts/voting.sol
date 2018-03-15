pragma solidity ^0.4.20;

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

library VotingLib {
    struct Vote {
        uint ID;
        uint votes;
        uint target;
        bool finished;
        bool successful;
        address to;
        uint256 money;
        mapping(address => bool) voted;
    }
    
    //updates the vote count and checks for completion
    function update(Vote storage self, address voter, bool voteFor, uint32 importance) public returns(bool){
        require(!self.finished);
        require(!self.voted[voter]);
        
        self.voted[voter] = true;
        
        if(voteFor){
            self.votes += importance;
        } else {
            self.votes -= importance;
        }
        
        if(self.votes >= self.target){
            self.finished = true;
        }
        
        return self.finished;
    }
}

contract Voting is Ownable {
    using VotingLib for VotingLib.Vote;
    
    event LogStartedVote(uint ID);
    event LogEndedVote(uint ID, address to, uint256 money);
    event LogSendMoney(address indexed from, uint256 amount);
    
    mapping(uint => VotingLib.Vote) public votes;
    mapping(address => uint32) isVoter;
    uint256 voters;
    uint256 votersImportance;
    bool initialized;
    
    modifier onlyVoter {
        require(isVoter[msg.sender] > 0);
        _;
    }
    
    modifier isInit {
        require(initialized);
        _;
    }
    
    modifier voteExists(uint voteID) {
        require(votes[voteID].ID != 0);
        _;
    }
    
    function Voting() public {
    }
    
    function initialize(address[] _voters) public {
        require(owner == msg.sender);
        require(_voters.length >= 3);
        require(!initialized);
        initialized = true;
        
        voters = _voters.length;
        
        for(uint32 i = 1; i<=_voters.length; i++){
            require(_voters[i - 1] != owner);
            
            isVoter[_voters[i - 1]] = i;
            votersImportance += i;
        }
    }
    
    function sendMoney() public payable {
        emit LogSendMoney(msg.sender, msg.value);
    }
    
    function startVote(address to, uint256 money) public isInit onlyOwner returns(uint){
        uint voteID = now;
        
        votes[voteID] = VotingLib.Vote({ID: voteID, votes: 0, target: votersImportance/2, finished: false, successful: false, to: to, money: money});
        emit LogStartedVote(voteID);
        
        return voteID;
    }
    
    function vote(uint id, bool voteFor) public isInit onlyVoter voteExists(id) {
        if(votes[id].update(msg.sender, voteFor, isVoter[msg.sender])){
            emit LogEndedVote(id, votes[id].to, votes[id].money);
        }
    }
    
    function withdraw(uint voteID) public isInit voteExists(voteID) {
        assert(votes[voteID].finished);
        assert(!votes[voteID].successful);
        require(votes[voteID].to == msg.sender);

        msg.sender.transfer(votes[voteID].money);
        votes[voteID].successful = true;
    }
}