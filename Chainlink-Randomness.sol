// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

abstract contract RandomWinnerGame is VRFConsumerBase, Ownable {
    uint256 public fee;
    bytes32 public keyHash;

    address[] public players;
    uint8 maxPlayers;
    bool public gameStarted;
    uint256 entryFee;
    uint256 public gameId;// the games gonna be perfomed multiple times


    event GameStarted(uint256 gameId, uint8 maxPlayers, uint256 entryFee);
    event PlayerJoined(uint256 gameId, address player);
    event GameEnded(uint256 gameId, address winner,bytes32 requestId);

    constructor(
        address vrfCoordinator,
        address linkToken,
        bytes32 vrfKeyHash,
        uint256 vrfFee
    ) VRFConsumerBase(vrfCoordinator, linkToken) {
        keyHash = vrfKeyHash;
        fee = vrfFee;
        gameStarted = false;
    }

    function startGame(uint8 _maxPlayers, uint256 _entryFee) public onlyOwner{
       require(!gameStarted,"Game is already started!!!");
       require(_maxPlayers > 0, "PLayer's count must be greater than that of zero"); 

       delete players;//empty players array if there is any from the previous game

       maxPlayers = _maxPlayers;

       gameStarted = true;

       entryFee = _entryFee;

       gameId += 1;

       emit GameStarted(gameId, maxPlayers, entryFee);
    }

    //WHEN A PLAYER WANT TO ENTER
    function joinGame() public payable{
        require(gameStarted, "Game has not been started yet!!!");
        require(msg.value >= entryFee, "You must pay the entry fee to participate");
        require(players.length < maxPlayers, "Game is full");

        players.push(msg.sender);

        emit PlayerJoined(gameId, msg.sender);

        if(players.length == maxPlayers){
            getRandomWinner();
        }
    }

}

/*
our contract <--> VRFConsumerBase <--> VRF Coordinator <--> External world
*/
