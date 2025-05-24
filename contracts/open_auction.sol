// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract OpenAuction {
    address payable public beneficiary;
    uint public auctionEndTime;

    address public highestBidder;
    address public highestBid;

    mapping(address => uint) pendingReturns;
    bool ended;

    //events that will be emitted on changes
    //maintianing the transaction log in blockchain. it cant be accessed by smart contract
    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    //the auction has already ended
    error AuctionAlreadyEnded();
    //there is already a higher or equal bid
    error BidNotHightEnough(uint highestBid);
    //the auction has not ended yet
    error AuctionBotYetEnded();
    //the function auctionEnd has already been called
    error AuctionEndAlreadyCalled();

    //payable is a keyword in solididty the marks a funciton or an address as capable of recieving ether
    constructor(uint biddingTime, address payable beneficiaryAddress) {
        beneficiary = beneficiaryAddress;
        auctionEndTime = block.timestamp + biddingTime;     //block.tiemstamp is current time
    }
}