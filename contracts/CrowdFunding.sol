// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CrowdFunding {
    string public name;
    string  public description;
    uint256 public goal;
    uint256 public deadline;
    address public owner;
    bool public paused;

    enum CampaginState {Active, Successful, Failed}
    CampaginState public state;

    struct Tier {
        string name;
        uint256 amount;
        uint256 backers;
    }

    struct Backer {
        uint256 totalContribution;
        mapping(uint256 => bool) fundedTiers; 
    }

    Tier[] public tiers;

    mapping(address => Backer ) public backers;

    modifier onlyOwner() {
require(msg.sender == owner, "Not the owner");
_;
    }

    modifier campaignOpen(){
        require(state == CampaginState.Active, "Campaign is not active ");
        _;
    }

    modifier notPaused() {
        require(!paused, "Contract is Pasued");
        _;
    }

    constructor(
        address _owner,
        string memory _name,
        string memory _description,
        uint256 _goal,
        uint256 _durationInDays
        ) {
            name = _name;
            description = _description;
            goal = _goal;
            deadline = block.timestamp + (_durationInDays * 1 days);
            owner = _owner;
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

        function fund(uint256 _tierIndex) public payable campaignOpen notPaused{
            require(_tierIndex < tiers.length, "tiers does not exits"); 
            require(msg.value == tiers[_tierIndex].amount, "incorrect amount");
            tiers[_tierIndex].backers++;

            backers[msg.sender].totalContribution += msg.value;
            backers[msg.sender].fundedTiers[_tierIndex] = true;

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

        function refund() public {
            checkAndUpdateCampaginState();
         require(state == CampaginState.Failed, "Refunds not successful");
            uint256 amount = backers[msg.sender].totalContribution;
            require(amount > 0, "No Contrubution Refunded");

            backers[msg.sender].totalContribution = 0;
            payable(msg.sender).transfer(amount); 

        }

        function hasFundedTier(address _backer, uint256 _tierIndex) public view returns (bool){
            return backers[_backer].fundedTiers[_tierIndex];
        }

        function getTiers() public view returns (Tier[] memory){
            return tiers;
        }

        function tooglePause() public onlyOwner {
            paused = !paused;
        }

        function getCampaignStatus() public view returns ( CampaginState) {
            if (state == CampaginState.Active && block.timestamp > deadline) {
                return address(this).balance >= goal ? CampaginState.Successful : CampaginState.Failed;
               
            }
            return state;
        } 

        function extendDeadline(uint256 _daysToAdd)public onlyOwner campaignOpen{
            deadline += _daysToAdd * 1 days;
        }
    
    
}