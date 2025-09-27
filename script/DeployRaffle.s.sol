// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {DeployRaffle} from "../script/DeployRaffle.s.sol";

contract DeployRaffleTest is Script {
    constructor() DeployRaffle() {}
}