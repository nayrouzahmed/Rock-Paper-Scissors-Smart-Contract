# Rock-Paper-Scissors-Smart-Contract
This project was an assignment in the blockchains course

## How the code works:
In the commit phase, the 2 players commit by sending h(address, choice, nonce)

During the reveal phase, they send their choice along with the nonce to be checked for consistency and correctness by the function reveal(). If the input is not consistent with the hash function or the choice is not 1 or 2 or 3, the function returns false.

After the reveal phase, the function computeWinner() calculates the result and adjust the values in the array pendingReturns.

The function auctionEnd() sets the variable ended:True indicating the end of the game and calls the function withdraw() for both players so the winner gets the reward placed in pendingReturns[winner]
