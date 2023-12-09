// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;
contract rock_paper_scissor {

    // address payable public beneficiary;
    uint public commitEnd;
    uint public revealEnd;
    bool public ended;
    bool public commitmentError;
    bool public placeBidError;
    address public player1;
    address public player2;
    uint8 public player1Choice;
    uint8 public player2Choice;
    uint public reward=address(this).balance;
    address public winner;

    mapping(address => bytes32) public commitments;

    // address public highestBidder;
    // uint public highestBid;


    // Allowed withdrawals of previous bids
    mapping(address => uint) pendingReturns;

    event AuctionEnded(address winner, uint highestBid);

    // Errors that describe failures.

    /// The function has been called too early.
    /// Try again at `time`.
    error TooEarly(uint time);
    /// The function has been called too late.
    /// It cannot be called after `time`.
    error TooLate(uint time);
    /// The function auctionEnd has already been called.
    error AuctionEndAlreadyCalled();

    // Modifiers are a convenient way to validate inputs to
    // functions. `onlyBefore` is applied to `bid` below:
    // The new function body is the modifier's body where
    // `_` is replaced by the old function body.
    modifier onlyBefore(uint time) {
        // if (block.timestamp >= time) revert TooLate(time);
        if (false) revert TooLate(time);
        _;
    }
    modifier onlyAfter(uint time) {
        // if (block.timestamp <= time) revert TooEarly(time);
        if (false) revert TooEarly(time);
        _;
    }

    constructor (
        uint commitTime,
        uint revealTime,
        address p1,
        address p2
    ) 
    payable 
    {
        player1 = p1;
        player2 = p2;
        commitEnd = block.timestamp + commitTime;
        revealEnd = commitEnd + revealTime;
    }


    function commit(bytes32 commitment)
        external
        payable
        onlyBefore(commitEnd)
    {
        commitments[msg.sender]=commitment;
    }

    function reveal(
        uint8 value,
        bytes32 secret
    )
        external
        onlyAfter(commitEnd)
        onlyBefore(revealEnd)
    {

        bytes32 bidToCheck = commitments[msg.sender];
        require(bidToCheck == keccak256(abi.encodePacked(msg.sender,value, secret)), "Inconsistent with commitment");
        require(value == 3 || value == 1 || value == 2, "invalid choice" );

        if (player1 == msg.sender) 
            player1Choice = value;
        
        else if (player2 == msg.sender) 
            player2Choice = value;

        // Make it impossible for the sender to re-claim
        // the same deposit.
        bidToCheck = bytes32(0);
        

    }

    /// Withdraw a bid that was overbid.
    function withdraw(address ad) internal {
        uint amount = pendingReturns[ad];
        if (amount > 0) {
            // It is important to set this to zero because the recipient
            // can call this function again as part of the receiving call
            // before `transfer` returns (see the remark above about
            // conditions -> effects -> interaction).
            pendingReturns[ad] = 0;

            payable(ad).transfer(amount);
        }
    }

    /// End the auction and send the highest bid
//     /// to the beneficiary.
    function computeWinner() external payable
    {
        int8 result;
        int8 difference = (int8(player1Choice) - int8(player2Choice)) % 3;
        if (difference == 1 || difference == -2)
            result=1;
        else if (difference == 2 || difference == -1)
            result=2;
        else
            result=0;
        if (result == 1)
        {
            pendingReturns[player1]=reward;
            winner=player1;
        }
        else if (result == 2)
        {
            pendingReturns[player2]=reward;
            winner=player2;
        }
        else {
            pendingReturns[player1]=reward/2;
            pendingReturns[player2]=reward/2;
        }
    }


    function auctionEnd()
        external
        onlyAfter(revealEnd)
    {
        if (ended) revert AuctionEndAlreadyCalled();
        ended = true;
        // beneficiary.transfer(highestBid);
        withdraw(player1);
        withdraw(player2);
    }

    function geth(uint8 choice, bytes32 secret)  external view
    returns (bytes32 h)
    {
        return keccak256(abi.encodePacked(msg.sender,choice,secret));
    }

}

