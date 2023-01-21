// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Vote{
    address public electionCommision;
    address public winner;

    struct Voter{
        string name;
        uint age;
        uint voterId;
        string gender;
        uint voteCandidateId;
        address voterAddress;
    }

    struct Candidate {
        string name;
        string party;
        uint age;
        string gender;
        uint candidateId;
        address candidateAddress;
        uint votes;

    }

    uint nextVoterId = 1;
    uint nextCandidateId = 1;
    uint startTime;
    uint endTime;

    mapping(uint => Voter) voterDetails;
    mapping(uint => Candidate) candidateDetails;

    bool stopVoting;

    constructor () {
        electionCommision = msg.sender;
    }


    // Registration of Candidate to Participating in Election
    function candidateRegister(string calldata _name,string calldata _party, uint _age,string calldata _gender)external {
        require(msg.sender!=electionCommision, "You are Election Commision");
        require(candidateVerification(msg.sender), "You have Already Registered");
        require(_age>=18,"Your Below Age");
        require(nextCandidateId<3,"Registration Full");

        candidateDetails[nextCandidateId]=Candidate(_name, _party, _age,_gender,nextCandidateId,msg.sender,0);
        nextCandidateId++;
    }

    // Verify if Candidate is Already Register or Not
    function candidateVerification(address _person) internal view returns(bool) {
        for(uint i=1; i<nextCandidateId; i++) {
            if(candidateDetails[i].candidateAddress==_person){
                return false;
            }
        }
        return true;
    }

    // Display the List of Candidate Registered
    function candidateList() public view returns(Candidate[] memory) {
        Candidate[] memory cArr = new Candidate[](nextCandidateId-1);
        for(uint i=1; i<nextCandidateId; i++){
            cArr[i-1]= candidateDetails[i];
        }
        return cArr;
    }

    // Registration of Voter who are going to Vote
    function voterRegister(string calldata _name, uint _age, string calldata _gender)external {
        require(msg.sender!=electionCommision, "You are Election Commision");
        require(voterVerification(msg.sender), "You have already Registered");
        require(_age>=18,"Your Below Age");
        voterDetails[nextVoterId]=Voter(_name,_age,nextVoterId,_gender,0,msg.sender);
        nextVoterId++;
    }

    // Verify if Voter Already Present or not
    function voterVerification(address _voter) internal view returns(bool) {
        for(uint i=1; i<nextVoterId; i++) {
            if(voterDetails[i].voterAddress==_voter){
                return false;
            }
        }
        return true;
    }

    // Display the list of Voters Registered
    function voterList() external view returns(Voter[] memory) {
        Voter[] memory vArr = new Voter[](nextVoterId-1);

        for(uint i=1; i<nextVoterId; i++){
            vArr[i-1]= voterDetails[i];
        }
        return vArr;
    }

    // Funtion for Voting for a Candidate
    function vote(uint _voterId, uint _id)external isVotingOver() {
        require(voterDetails[_voterId].voteCandidateId==0, "You have Already Voted.");
        require(voterDetails[_voterId].voterAddress==msg.sender, "You are not Registered.");
        require(block.timestamp>startTime, "Voting has not Started.");
        require(nextCandidateId>2, "Candidate Registration is not Done Yet.");
        require(_id>0 && _id<3, "Candidate not Registered.");
        voterDetails[_voterId].voteCandidateId= _id;
        candidateDetails[_id].votes++;
    }

    // Fuction for Voting Start Time and End Time
    function voteTime(uint _startTime, uint _endTime) external {
        require(electionCommision==msg.sender, "You are not from Election Commission.");
        startTime = block.timestamp + _startTime;
        endTime = startTime + _endTime;
        stopVoting = false;
    }

    // Function for Voting Status 
    function votingStatus() external view returns(string memory) {
        if(startTime == 0) {
            return "Voting not Started..";
        } else if((startTime != 0 && endTime > block.timestamp) && stopVoting == false) {
            return "Voting is Process..";
        } else {
            return "Voting Ended..";
        }
    }


    // Function to Display Result of Voting
    function result() external {
        require(electionCommision == msg.sender, "You are not from Election Commision.");
        Candidate[] memory rArr = new Candidate[](nextCandidateId-1);
        rArr = candidateList();
        if(rArr[0].votes > rArr[1].votes) {
            winner = rArr[0].candidateAddress;
        }
        else {
            winner = rArr[1].candidateAddress;
        }
    }

    // Funtion to Stop Voting in Emergency Situation
    function emergency() public {
        require(electionCommision == msg.sender, "You are not from Election Commision.");
        stopVoting = true;
    }



    modifier isVotingOver() {
        require(endTime>block.timestamp || stopVoting, "Voting is Over");
        _;
    }
}