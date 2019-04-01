# Tic-Tac-Toe AI

NxN version of Tic Tac Toe with Artificial Inteligence based on Alpha Beta pruning algorithm with my own heuristic.

## Algorithm
The Alpha Beta pruning algorithm is a node amount limiting version of MinMax algorithm which search a tree of games in order to find the best possible move - the most beneficial for himself and most harmful for the opponent assuming the opponent always takes the best move for himself. In a nutshell: we always take maximum payoff of player's moves and minimum of opponent ones to evaluate the best possible move.

## Running game
IDE and language version:
- Xcode 10.1
- Swift 4.2

To run simply open `Tic Tac Toe.xcodeproj` with XCode and click Run button (⌘+R)

You can easily adjust game and AI parameters by editing `defaults` variable in `main.swift`.
