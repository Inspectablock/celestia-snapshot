// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Polling {
    //string public name;
    address public owner;

    uint private _pollId;

    struct Poll {
      uint id;
      string title;
      string description;
      uint startDate;
      uint endDate;
      bool published;
    }
    
    /* here we create lookups for polls by id and polls by ipfs hash */
    mapping(uint => Poll) private idToPoll;
    mapping(string => Poll) private hashToPoll;

    /* events facilitate communication between smart contractsand their user interfaces  */
    /* i.e. we can create listeners for events in the client and also use them in The Graph  */
    event PollCreated(uint id, string title, string hash, uint startDate, uint endDate);
    event PollUpdated(uint id, string title, string hash, bool published);

    /* when the poll is deployed set the creator as the owner of the contract */
    constructor() {
        owner = msg.sender;
    }

    /* transfers ownership of the contract to another address */
    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    /* fetches an individual poll by the description hash */
    function fetchPoll(string memory hash) public view returns(Poll memory){
      return hashToPoll[hash];
    }

    /* creates a new poll */
    function createPoll(string memory title, string memory hash, uint startDate, uint endDate) public onlyOwner {
        _pollId = _pollId + 1;
        Poll storage poll = idToPoll[_pollId];
        poll.id = _pollId;
        poll.title = title;
        poll.startDate = startDate;
        poll.endDate = endDate;
        poll.published = true;
        poll.description = hash;
        hashToPoll[hash] = poll;
        emit PollCreated(_pollId, title, hash, startDate, endDate);
    }

    /* updates an existing poll */
    function updatePoll(uint pollId, string memory title, string memory hash, bool published) public onlyOwner {
        Poll storage poll =  idToPoll[pollId];
        poll.title = title;
        poll.published = published;
        poll.description = hash;
        idToPoll[pollId] = poll;
        hashToPoll[hash] = poll;
        emit PollUpdated(poll.id, title, hash, published);
    }

    /* fetches all polls */
    function fetchPolls() public view returns (Poll[] memory) {
        uint itemCount = _pollId;

        Poll[] memory polls = new Poll[](itemCount);
        for (uint i = 0; i < itemCount; i++) {
            uint currentId = i + 1;
            Poll storage currentItem = idToPoll[currentId];
            polls[i] = currentItem;
        }
        return polls;
    }

    /* this modifier means only the contract owner can */
    /* invoke the function */
    modifier onlyOwner() {
      require(msg.sender == owner);
    _;
  }
}