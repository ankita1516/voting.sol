// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
contract VotingSystem {
 enum ElectionState { NOT_STARTED, ONGOING, ENDED }

 struct Candidate {
 uint id;
 string name;
 string proposal;
 uint votes;
 }
 struct Voter {
 address voterAddress;
 bool hasVoted;
 bool hasDelegate;
 address delegate;
 }
 address public admin;
 ElectionState public electionState;
 mapping(uint => Candidate) public candidates;
 mapping(address => Voter) public voters;
 uint public totalCandidates;
 uint public totalVoters;
 event NewCandidateAdded(uint candidateId, string name);
 event VoteCasted(address voter, uint candidateId);
 event ElectionEnded(uint winningCandidateId);

 modifier onlyAdmin() {
 require(msg.sender == admin, "Only the admin can perform this action");
 _;
 }
 modifier onlyDuringElec4on() {
 require(electionState == ElectionState.ONGOING, "Election is not ongoing");
 _;
 }

 constructor() {
 admin = msg.sender;
 electionState = ElectionState.NOT_STARTED;
 totalCandidates = 0;
 totalVoters = 0;
 }
 function addCandidate(string memory _name, string memory _proposal) public {
 totalCandidates++;
 candidates[totalCandidates] = Candidate(totalCandidates, _name, _proposal, 0);
 emit NewCandidateAdded(totalCandidates, _name);
 }

 function addVoter(address _voter) public onlyDuringElec4on {
 require(voters[_voter].voterAddress == address(0), "Voter already exists");
 totalVoters++;
 voters[_voter] = Voter(_voter, false, false, address(0));
 }

 function startElec4on() public onlyAdmin {
 require(electionState == ElectionState.NOT_STARTED, "Election has already started");
 electionState = ElectionState.ONGOING;
 }

 function getCandidateDetails(uint _candidateId) public view returns (uint, string memory, string memory, uint) {
 require(_candidateId > 0 && _candidateId <= totalCandidates, "Invalid candidate ID");
 Candidate storage candidate = candidates[_candidateId];
 return (candidate.id, candidate.name, candidate.proposal, candidate.votes);
 }

 function getWinner() public view returns (uint) {
 require(electionState == ElectionState.ENDED, "Election has not ended yet");

 uint winningCandidateId = 0;
 uint maxVotes = 0;

 for (uint i = 1; i <= totalCandidates; i++) {
 if (candidates[i].votes > maxVotes) {
 maxVotes = candidates[i].votes;
 winningCandidateId = candidates[i].id;
 }
 }

 return winningCandidateId;
 }

 function delegateVote(address _delegate) public onlyDuringElec4on {
 require(voters[msg.sender].voterAddress != address(0), "Caller is not a registered voter");
 require(!voters[msg.sender].hasVoted, "Caller has already voted");
 require(!voters[msg.sender].hasDelegate, "Caller has already delegated the vote");

 voters[msg.sender].hasDelegate = true;
 voters[msg.sender].delegate = _delegate;
 }

 function castVote(uint _candidateId) public onlyDuringElec4on {
 require(voters[msg.sender].voterAddress != address(0), "Caller is not a registered voter");
 require(!voters[msg.sender].hasVoted, "Caller has already voted");

 if (voters[msg.sender].hasDelegate) {
 address delegate = voters[msg.sender].delegate;
 require(delegate != msg.sender, "Caller cannot delegate vote to themselves");
 require(voters[delegate].hasVoted, "Delegate has not voted yet");
 _candidateId = candidates[getWinner()].id; // Delegate's vote goes to the winning candidate
 }

 require(_candidateId > 0 && _candidateId <= totalCandidates, "Invalid candidate ID");
 candidates[_candidateId].votes++;
 voters[msg.sender].hasVoted = true;
 emit VoteCasted(msg.sender, _candidateId);
 }

 function endElec4on() public onlyAdmin onlyDuringElec4on {
 electionState = ElectionState.ENDED;
 uint winningCandidateId = getWinner();
 emit ElectionEnded(winningCandidateId);
 }

 function getVotesForCandidate(uint _candidateId) public view returns (uint) {
 require(_candidateId > 0 && _candidateId <= totalCandidates, "Invalid candidate ID");
 return candidates[_candidateId].votes;
 }

 function getVoterProfile(address _voterAddress) public view returns (string memory , bool, bool) {
 Voter storage voter = voters[_voterAddress];
 require(voter.voterAddress != address(0), "Voter does not exist");

 string memory candidateVoted = "";
 if (voter.hasVoted) {
 candidateVoted = candidates[getWinner()].name;
 }
 return (candidateVoted,bool (voter.hasDelegate), voter.hasVoted);
 }
} 
