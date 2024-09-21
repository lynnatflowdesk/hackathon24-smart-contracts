// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract IdeaVoting is Ownable {
    IERC1155 public token;
    uint256 public WINNER_RATIO = 70;
    uint256 public VOTER_RATIO = 30;

    struct Idea {
        address proposer;
        string description;
        uint256 voteCount;
        mapping(address => uint256) votesByAddress; // Track votes per address
    }

    uint256 public round;
    bool public isRoundActive;
    uint256 public totalPool;

    mapping(uint256 => mapping(uint256 => Idea)) public roundToIdeas; // round => (ideaId => Idea)
    mapping(uint256 => uint256) public roundToIdeaCount; // round => number of ideas
    mapping(uint256 => address[]) public roundToVoters; // round => voters who voted for winner
    mapping(uint256 => mapping(address => bool)) public hasProposedInRound; // round => (address => hasProposed)

    constructor(IERC1155 _token, address initialOwner) Ownable(initialOwner) {
        token = _token;
    }

    modifier onlyActiveRound() {
        require(isRoundActive, "No active round");
        _;
    }

    function start() external onlyOwner {
        require(!isRoundActive, "Round is already active");
        round++;
        isRoundActive = true;
        totalPool = 0; // Reset the pool for the new round
    }

    function propose(string memory _description) external onlyActiveRound {
        require(!hasProposedInRound[round][msg.sender], "Address has already proposed an idea this round");

        uint256 ideaId = roundToIdeaCount[round]++;
        Idea storage newIdea = roundToIdeas[round][ideaId];
        newIdea.proposer = msg.sender;
        newIdea.description = _description;
        newIdea.voteCount = 0;

        hasProposedInRound[round][msg.sender] = true; // Mark the address as having proposed
    }

    function vote(uint256 ideaId, uint256 voteNumber) external onlyActiveRound {
        require(ideaId < roundToIdeaCount[round], "Invalid ideaId");
        Idea storage idea = roundToIdeas[round][ideaId];

        // Transfer IERC1155 tokens from voter to the contract
        require(token.transferFrom(msg.sender, address(this), voteNumber), "Token transfer failed");

        idea.voteCount += voteNumber;
        idea.votesByAddress[msg.sender] += voteNumber;
        totalPool += voteNumber;

        // Add voter to list (only once per round)
        bool isNewVoter = true;
        for (uint256 i = 0; i < roundToVoters[round].length; i++) {
            if (roundToVoters[round][i] == msg.sender) {
                isNewVoter = false;
                break;
            }
        }
        if (isNewVoter) {
            roundToVoters[round].push(msg.sender);
        }
    }

    function end() external onlyOwner onlyActiveRound {
        isRoundActive = false;
        uint256 winningIdeaId = findWinner();

        // Distribute the pool
        uint256 winnerReward = (totalPool * WINNER_RATIO) / 100;
        uint256 voterReward = (totalPool * VOTER_RATIO) / 100;

        Idea storage winningIdea = roundToIdeas[round][winningIdeaId];

        // Transfer winner reward to proposer
        require(token.transfer(winningIdea.proposer, winnerReward), "Winner reward transfer failed");

        // Pick a random voter for the voter reward (for simplicity, first voter)
        if (roundToVoters[round].length > 0) {
            address randomVoter = roundToVoters[round][0];
            require(token.transfer(randomVoter, voterReward), "Voter reward transfer failed");
        }
    }

    function findWinner() internal view returns (uint256) {
        uint256 winningVoteCount = 0;
        uint256 winningIdeaId = 0;

        for (uint256 i = 0; i < roundToIdeaCount[round]; i++) {
            if (roundToIdeas[round][i].voteCount > winningVoteCount) {
                winningVoteCount = roundToIdeas[round][i].voteCount;
                winningIdeaId = i;
            }
        }

        return winningIdeaId;
    }

    function getIdeasForCurrentRound() external view returns (
        uint256[] memory ideaIds,
        address[] memory proposers,
        string[] memory descriptions,
        uint256[] memory voteCounts
    ) {
        uint256 ideaCount = roundToIdeaCount[round];

        ideaIds = new uint256[](ideaCount);
        proposers = new address[](ideaCount);
        descriptions = new string[](ideaCount);
        voteCounts = new uint256[](ideaCount);

        for (uint256 i = 0; i < ideaCount; i++) {
            Idea storage idea = roundToIdeas[round][i];
            ideaIds[i] = i;
            proposers[i] = idea.proposer;
            descriptions[i] = idea.description;
            voteCounts[i] = idea.voteCount;
        }
    }
}
