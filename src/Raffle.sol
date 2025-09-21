// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title A sample raffle contract
 * @author Jordan Finn
 * @notice This contract is a sample raffle contract
 * @dev Implements Chainlink VRF v2 for randomness
 */
contract Raffle {
    // Errors
    error Raffle__SendMoreToEnterRaffle();
    
    uint256 private immutable I_ENTRANCE_FEE;
    address payable[] private s_players;

    constructor(uint256 entranceFee) {
        I_ENTRANCE_FEE = entranceFee;
    }
    
    function enterRaffle() public payable {
        if (msg.value < I_ENTRANCE_FEE) {
            revert Raffle__SendMoreToEnterRaffle();
        }
    }

    function pickWinner() public {
    
    }

    // Getter functions
    function getEntranceFee() public view returns (uint256) {
        return I_ENTRANCE_FEE;
    }
}