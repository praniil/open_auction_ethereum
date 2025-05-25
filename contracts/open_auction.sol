// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract OpenAuction {
    address payable public beneficiary;
    uint public auctionEndTime;

    address public highestBidder;
    uint public highestBid;

    mapping(address => uint) pendingReturns;
    bool ended;

    //events that will be emitted on changes
    //maintianing the transaction log in blockchain. it cant be accessed by smart contract
    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    //the auction has already ended
    error AuctionAlreadyEnded();
    //there is already a higher or equal bid
    error BidNotHighEnough(uint highestBid);
    //the auction has not ended yet
    error AuctionNotYetEnded();
    //the function auctionEnd has already been called
    error AuctionEndAlreadyCalled();

    //payable is a keyword in solididty the marks a funciton or an address as capable of recieving ether
    constructor(uint biddingTime, address payable beneficiaryAddress) {
        beneficiary = beneficiaryAddress;
        auctionEndTime = block.timestamp + biddingTime;     //block.tiemstamp is current time
    }

    function bid() external payable {   //payable is required for the function to be able to receive the Ether
        if (block.timestamp > auctionEndTime) {
            revert AuctionAlreadyEnded();
        }

        if (msg.value <= highestBid) {
            revert BidNotHighEnough(highestBid);
        }

        if (highestBid != 0) {
            pendingReturns[highestBidder] += highestBid;
        }
        
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncreased(msg.sender, msg.value);
    } 

    function withdraw() external returns (bool) {
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {
            pendingReturns[msg.sender] = 0;     //setting pendingReturns[msg.sender] = 0 prevents the double spending attack
            if (!payable(msg.sender).send(amount)) {
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    function auctionEnd() external {
        // It is a good guideline to structure functions that interact
        // with other contracts (i.e. they call functions or send Ether)
        // into three phases:
        // 1. checking conditions
        // 2. performing actions (potentially changing conditions)
        // 3. interacting with other contracts

        //1.Condition
        if (block.timestamp < auctionEndTime) {
            revert AuctionNotYetEnded();
        }
        if (ended)
            revert AuctionEndAlreadyCalled();

        //2. Effects
        ended = true;
        emit AuctionEnded(highestBidder, highestBid);

        //3. Interaction
        beneficiary.transfer(highestBid);
    }
}