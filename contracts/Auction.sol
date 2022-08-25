// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.9;

contract Auction {

    // state variables
    address payable public BeneficiaryOfAuction;
    uint public AmountBeneficiaryGets;
    uint public AuctionEndTime;
    bool ended;
    bool cancelled;
    
    // current status of the auction
    address HighestBidder;
    uint HighestBid;
    mapping (address => uint) BidOfAllToBeReturned;

    // events to tell us when anyone adds more funds to his bid,
    // or when the Auction has Ended, Cancelled Or fund withdrawn

    event AddedToBid(address bidder, uint amount);
    event AuctionEnded(address WhoGotHighestBid, uint AmountOfHighestBidder);
    event WithdrawnBid(address bidder, uint amountBidded);
    event AuctionCancelled();

    //Defining Our Beneficiary and End time on deployment
    constructor(address payable _beneficiaryOfAuction, uint _auctionEndTime) {
        BeneficiaryOfAuction = _beneficiaryOfAuction;
        AuctionEndTime = block.timestamp + _auctionEndTime;
    }

    // By default, User's bids are locked up in the BidOfAllToBeReturned[] mapping till auction ends once they make a bid,
    // but if a user has made a bid, we want to allow them top up the existing bid to become the Highest Bidder,
    // instead of making a totally new bid when they call the Bid() function, provided the Auction hasn't ended.

    // So after checking they're sending an amount higher than HighestBid, we first check if the user has made
    // a bid already, then allow them to top up their bids when they call the bid function again by transfering them 
    // back their previous bid amount and assigning the new bid to their address in our BidOfAllToBeReturned[] mapping.
    // And emit an event to show they just increased their bid.

    function Bid() payable public{
        require(block.timestamp < AuctionEndTime, "This Auction is Over Already, Thank You");
        require(!cancelled);

        if(msg.value > HighestBid) {
            if (BidOfAllToBeReturned[msg.sender] > 0) {
                uint amount = BidOfAllToBeReturned[msg.sender];
                payable(msg.sender).transfer(amount);
            }

            BidOfAllToBeReturned[msg.sender] = msg.value;
            HighestBidder = msg.sender;
            HighestBid = msg.value;
            emit AddedToBid(msg.sender, msg.value);
        }
        else {
            revert("Bid not high enough");
        }

    }

    function AuctionHasEnded() public {
        require(block.timestamp > AuctionEndTime, "You can't end the Auction yet, Time not reached");
        if (ended) revert ("The Auction is Over now");
        ended = true;
        emit AuctionEnded(HighestBidder, HighestBid);

        // Send funds to the beneficiary once Auction ends

        BeneficiaryOfAuction.transfer(HighestBid);        
    }

    function CancelAuction() public returns(bool) {
        cancelled = true;
        emit AuctionCancelled();
        return true;
    }

    function WithdrawBids() public payable returns(bool) {
        require(ended || cancelled, "You can't withdraw when Auction is still on, Please Wait");

        uint amount = BidOfAllToBeReturned[msg.sender];
        if(amount > 0) {
            BidOfAllToBeReturned[msg.sender] = 0;
        }
        if(!payable(msg.sender).send(amount)) {
            BidOfAllToBeReturned[msg.sender] = amount;
        }
        emit WithdrawnBid(msg.sender, amount);
        return true;
    }


}