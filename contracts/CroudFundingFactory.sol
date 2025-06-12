// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {CroudFunding} from "./CroudFunding.sol";


contract CrowdFundingFactory {
    address public owner;
    bool public paused;

    struct Campaign {
        address campaignAddress;
        address owner;
        string name;
        uint256 creationTime;
    }

    Campaign[] public campaigns;
    mapping(address => Campaign[]) public userCampigns;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }
    function createCampaign(
        string memory _name,
        string memory _description,
        uint256 _goal,
        uint256 _durationInDays
    ) external notPaused {
        CroudFunding newCampaign = new CroudFunding(
            msg.sender,
            _name,
            _description,
            _durationInDays,
            _goal

        );
        address campaignAddress = address(newCampaign);

        Campaign memory campaign = Campaign({
            campaignAddress: campaignAddress,
        owner: msg.sender,
            name: _name,
            creationTime: block.timestamp
        });
        campaigns.push(Campaign);
        userCampigns[msg.sender].push();
    }
}