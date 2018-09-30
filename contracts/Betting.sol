pragma solidity ^0.4.23;
//delare version

contract Betting {
    //constructor
    //declare owner variable for administrating
    address public owner;
    
    uint public totalSlots = 2;  //default value
    uint public numberOfBets;  
    uint public lastWinnerNumber;
    uint public totalBet;   //total bet value
    uint public betValue = 1 ether;
    
    address[] players;
    mapping(uint => address[]) numberToPlayers; //all players choosing this number
    mapping(address => uint) public playerToNumber; //return the number chosen by this player
    
    constructor (uint _totalSlots, uint _betValue) public { //syntax for new version
        owner  = msg.sender;
        if(_totalSlots > 0) totalSlots = _totalSlots;
        if(_betValue  > 0) betValue = _betValue;
    }
    
    //modifier used to validate all requirements + can be reproduced
    //if not satisfy the requirement in modifier, the transaction will be reversed
    modifier validBet(uint betNumber){
        require(playerToNumber[msg.sender] == 0);
        require(msg.value >= betValue);
        require(numberOfBets < 3);
        require(betNumber >= 1 && betNumber <= 10);
        _; //place for remain code of function
    }
    
    function bet(uint betNumber) public payable validBet(betNumber) {
        if (msg.value > betValue) {
            msg.sender.transfer(msg.value - betValue); //return overhead value to bettor
        }
        playerToNumber[msg.sender] = betNumber;
        players.push(msg.sender);
        numberToPlayers[betNumber].push(msg.sender);
        numberOfBets += 1;
        totalBet += msg.value;
        if(numberOfBets >= totalSlots) {
            distributePrizes();
        }
    }

    function distributePrizes() internal {
        uint winnerNumber = generateRandomNumber();
        address[] memory winners = numberToPlayers[winnerNumber]; //keyword memory to make temp variable
        if (winners.length > 0) {
            uint winnerEtherAmount = totalBet / winners.length;
            for (uint i = 0; i < numberToPlayers[winnerNumber].length; i++) {
                numberToPlayers[winnerNumber][i].transfer(winnerEtherAmount);
            }
        }
        lastWinnerNumber = winnerNumber;
        reset();
    }
    
    function generateRandomNumber() public view returns (uint) { //view - not edit data, return uint value
        return (block.number % 10 + 1);
    }
    
    function reset() internal {
        for (uint i = 1; i <= 10; i++) {
            numberToPlayers[i].length = 0;
        }
    
        for (uint j = 0; j < players.length; j++) {
            playerToNumber[players[j]] = 0;
        }
    
        players.length = 0;
        totalBet = 0;
        numberOfBets = 0;
    }
    
    function kill() public { //cancel contract
        require(msg.sender == owner); //check if msg.sender is owner
        selfdestruct(owner);
    }
}