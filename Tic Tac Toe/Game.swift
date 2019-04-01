import Foundation

enum GameState {
    case resolved, pending
}

class Game {
    var board : Board?
    var players : [Player]
    let boardSize : Int
    let winningValue : Int
    private var currentPlayerID : Int = 1

    init(boardSize : Int, winningValue : Int) throws {
        if (winningValue > boardSize) { throw "Winning value exceeds board size" }
        self.boardSize = boardSize
        self.winningValue = winningValue
        self.players = [Player]()
    }

    func initNewGame() throws -> Game {
        self.board = try Board(game: self, ofSize: boardSize)
        return self
    }

    func addPlayer(playerSymbol symbol: Character) throws -> Player {
        for player in players {
            if player.getSymbol() == symbol {
                throw "Player \(symbol) already exists"
            }
        }

        let newPlayer = Player(playerID: currentPlayerID, playerSymbol: symbol)
        players.append(newPlayer)
        currentPlayerID += 1

        return newPlayer
    }

    func move(player : Player, toPosition position : (Int,Int)) {
        let (row,col) = position
        board?.field[row][col] = player
    }
}
