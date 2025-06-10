// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CroudFunding {
    string public name;
    string  public description;
    uint256 public goal;
    uint256 public deadline;
    address public owner;

    enum CampaginState {Active, Successful, Failed}
    CampaginState public state;

    struct Tier {
        string name;
        uint256 amount;
        uint256 backers;
    }

    Tier[] public tiers;

    modifier onlyOwner() {
require(msg.sender == owner, "Not the owner");
_;
    }

    modifier campaignOpen(){
        require(state == CampaginState.Active, "Campaign is not active ");
        _;
    }

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
            state = CampaginState.Active;
        }

        function checkAndUpdateCampaginState() internal {
            if (state == CampaginState.Active) {
                if (block.timestamp >= deadline) {
                    state = address(this).balance >= goal ? CampaginState.Successful : CampaginState.Failed;
                } else {
  state = address(this).balance >= goal ? CampaginState.Successful : CampaginState.Active;
                }
            }
        }

        function fund(uint256 _tierIndex) public payable campaignOpen {
            require(_tierIndex < tiers.length, "tiers does not exits"); 
            require(msg.value == tiers[_tierIndex].amount, "incorrect amount");
            tiers[_tierIndex].backers++;

            checkAndUpdateCampaginState();
        }

        function addTier( string memory _name,
            uint256 _amount) public onlyOwner {
                require(_amount > 0, "Amount must be greater than zero");

                tiers.push(Tier(_name, _amount, 0));
           

        }

        function removeTier(uint256 _index) public onlyOwner{
            require(_index < tiers.length, "tires does not exits");
            tiers[_index] = tiers[tiers.length -1];
            tiers.pop();
        }


        function withdraw() public onlyOwner{
checkAndUpdateCampaginState();
require(state == CampaginState.Successful, "Campagin not successful");
            uint256 balance = address(this).balance;
            require(balance > 0, "No balance to withdraw.");

            payable(owner).transfer(balance);
        }

        function getContractBalance() public view returns (uint256) {
            return address(this).balance;
        }
    
}