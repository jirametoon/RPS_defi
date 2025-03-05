// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

// Import the CommitReveal and TimeUnit contracts
import "./CommitReveal.sol";
import "./TimeUnit.sol";

contract RPS is CommitReveal, TimeUnit {

    uint public numPlayer = 0;      // Counter for the number of players, max 2
    uint public reward = 0;         // Total amount of ether collected as rewards
    address[] public players;       // Array to store player addresses

    mapping(address => uint) public player_commit;   // Tracks player's commits
    mapping(address => bool) public player_revealed; // Tracks if a player has revealed

    // Fixed list of allowed addresses that can play the game
    address[4] private allowedAddresses = [
        0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,
        0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,
        0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db,
        0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB
    ];

    // Modifier to restrict participation to allowed addresses
    modifier isAllowed() {
        require(isAddressAllowed(msg.sender));
        _;
    }

    // function to check if an address is in the allowed list
    function isAddressAllowed(address _addr) private view returns (bool) {

        for (uint i = 0; i < allowedAddresses.length; i++) {
            if (allowedAddresses[i] == _addr) {
                return true;
            }
        }
        return false;
    }

    //  function for players to join the game, must send 1 ether
    function addPlayer() public payable isAllowed {

        require(numPlayer < 2);
        require(msg.value == 1 ether);
        players.push(msg.sender);
        numPlayer++;
        reward += msg.value;

        if (numPlayer == 1) {
            setStartTime(); // Initialize time tracking
        }
    }

    // Players commit their choice by sending a hash
    function commitChoice(bytes32 hash) public isAllowed {

        require(numPlayer == 2);
        require(!player_revealed[msg.sender]);
        commit(hash);
        player_commit[msg.sender] = uint(hash); // Store hash for later verification
    }

    // Players reveal their choice and the game checks if both have revealed to end the game
    function revealChoice(uint choice, bytes32 nonce) public {

        require(player_commit[msg.sender] == uint(keccak256(abi.encodePacked(choice, nonce))));
        reveal(keccak256(abi.encodePacked(choice, nonce)));
        player_revealed[msg.sender] = true;
        checkEndGame();
    }

    // Check if all players have revealed and then distribute rewards and reset the game
    function checkEndGame() private {

        if (player_revealed[players[0]] && player_revealed[players[1]]) {
            distributeRewards();
            resetGame();
        }
    }

    // Distribute the rewards between both players
    function distributeRewards() private {

        // Retrieve choices of both players
        uint p0Choice = player_commit[players[0]];
        uint p1Choice = player_commit[players[1]];

        // Convert player addresses to payable
        address payable account0 = payable(players[0]);
        address payable account1 = payable(players[1]);

        // Determine the winner or declare a tie based on the game logic
        if ((p0Choice + 1) % 3 == p1Choice) {
            // Player 1 wins, transfer all reward to player 1
            account1.transfer(reward);
        }
        else if ((p1Choice + 1) % 3 == p0Choice) {
            // Player 0 wins, transfer all reward to player 0
            account0.transfer(reward);
        }
        else {
            // Tie, split the reward between both players
            account0.transfer(reward / 2);
            account1.transfer(reward / 2);
        }
    }

    // Reset the game to allow new players to join
    function resetGame() private {
        numPlayer = 0;
        reward = 0;
        delete players;
        resetTime(); // Reset the timer
    }

    // Reset the time tracker if the game is inactive after 10 minutes
    function resetTime() private {
        startTime = 0; // Reset start time
    }

    // Function to allow withdrawal if the game is inactive
    function withdrawIfInactive() public {

        require(elapsedMinutes() > 10);
        require(numPlayer < 2, "Game still active");

        for (uint i = 0; i < numPlayer; i++) {
            payable(players[i]).transfer(reward / numPlayer);
        }
        resetGame();
    }
}
