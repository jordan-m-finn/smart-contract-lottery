// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
// import {VRFV2PlusClient} from "@chainlinkcontracts/src/v0.8/dev/vrf/libraries/VRFV2PlusClient.sol";

/**
 * @title A sample raffle contract
 * @author Jordan Finn
 * @notice This contract is a sample raffle contract
 * @dev Implements Chainlink VRF v2 for randomness
 */
contract Raffle is VRFConsumerBaseV2Plus {
    // Errors
    error Raffle__SendMoreToEnterRaffle();
    error Raffle__TransferFailed();
    error Raffle__RaffleNotOpen();

    // Type declarations
    enum RaffleState {
        OPEN,
        CALCULATING
    }

    // State variables
    // @dev the duration of the raffle in seconds
    uint256 private immutable I_ENTRANCE_FEE;
    uint256 private immutable I_INTERVAL;
    uint256 private immutable I_SUBSCRIPTION_ID;
    bytes32 private immutable I_KEY_HASH;
    uint32 private immutable I_NUM_WORDS = 1;
    uint32 private immutable I_CALLBACK_GAS_LIMIT;
    RaffleState private s_raffleState;

    uint16 private constant REQUEST_CONFIRMATIONS = 3;

    uint256 private s_lastTimeStamp;

    address payable[] private s_players;
    address private s_recentWinner;

    event RaffleEntered(address indexed player);
    event WinnerPicked(address indexed winner);

    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 gasLane,
        uint256 subscriptionId,
        uint32 callbackGasLimit,
        uint32 numWords
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        I_ENTRANCE_FEE = entranceFee;
        I_INTERVAL = interval;
        I_KEY_HASH = gasLane;
        I_SUBSCRIPTION_ID = subscriptionId;
        I_CALLBACK_GAS_LIMIT = callbackGasLimit;
        I_NUM_WORDS = numWords;
        s_lastTimeStamp = block.timestamp;
        s_raffleState = RaffleState.OPEN;
    }

    function enterRaffle() external payable {
        if (msg.value < I_ENTRANCE_FEE) {
            revert Raffle__SendMoreToEnterRaffle();
        }

        // `Semaphore` status check
        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle__RaffleNotOpen();
        }
        
        s_players.push(payable(msg.sender));
        emit RaffleEntered(msg.sender);
    }

    // Get a random number,
    // Use that random number to pick a player,
    // Be automatically called
    function pickWinner() external {
        if ((block.timestamp - s_lastTimeStamp) < I_INTERVAL) {
            revert();
        }

        // `Semaphore` status update
        s_raffleState = RaffleState.CALCULATING;

        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient.RandomWordsRequest({
            keyHash: I_KEY_HASH,
            subId: I_SUBSCRIPTION_ID,
            requestConfirmations: REQUEST_CONFIRMATIONS,
            callbackGasLimit: I_CALLBACK_GAS_LIMIT,
            numWords: I_NUM_WORDS,
            // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
            extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: false}))
        });

        uint256 requestId = s_vrfCoordinator.requestRandomWords(request);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal virtual override {
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;

        // `Semaphore` status update & reset logic for next raffle
        s_raffleState = RaffleState.OPEN;
        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp;

        (bool success,) = recentWinner.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle__TransferFailed();
        }
        emit WinnerPicked(s_recentWinner);
    }

    // Getter functions
    function getEntranceFee() public view returns (uint256) {
        return I_ENTRANCE_FEE;
    }
}
