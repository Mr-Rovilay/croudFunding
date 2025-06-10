// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CroudFunding {
    string public name;
    string  public description;
    uint256 public goal;
    uint256 public deadline;
    address public owner;

    constructor(
        string memory _name,
        string memory _description,
        uint256 _goal,
        uint256 _durationInDays
        ) {
            name = _name;
            description = _description;
            goal = _goal;
            deadline = block.timestamp + (_durationInDays * 1 days);
            owner = msg.sender;
        }
        function fund() public payable {
            require(msg.value > 0, "Must be greater than 0.");
            require(block.timestamp < deadline, "Campaign has ended");
        }
        function withdraw() public {}

        function getContractBalance() public view returns (uint256) {}
    
}