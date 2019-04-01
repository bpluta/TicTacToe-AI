import Foundation

extension String: Error {}

let defaults = (
    // game parameters
    boardSize: 5,
    winningValue: 4,
    playerSymbol: "⭕",
    opponentSymbol: "❌",

    // ai parameters
    offensiveValue: 10,
    deffensiveValue: 9,
    searchDepth: 3,
    searchRadius: 1
)

func playTicTacToe() throws {
    // game initializing
    let myGame = try Game(boardSize: defaults.boardSize, winningValue: defaults.winningValue).initNewGame()

    let player = try myGame.addPlayer(playerSymbol: Character(defaults.playerSymbol))
    let opponent = try myGame.addPlayer(playerSymbol: Character(defaults.opponentSymbol))

    let ai = MoveEvaluator(myGame, defaults.offensiveValue, defaults.deffensiveValue, defaults.searchDepth, defaults.searchRadius)
    var (gameState, winner) : (GameState,Player?)

    // gameplay loop
    repeat{
        myGame.board!.printBoard(withIndices: true)

        handleSetElement(myGame, player)
        (gameState, winner) = myGame.board!.getResult()
        if (gameState == .resolved) { break }

        handleAi(myGame, ai, opponent)
        (gameState, winner) = myGame.board!.getResult()

    } while (gameState != .resolved)

    myGame.board!.printBoard(withIndices: true)
    printResult(gameState, winner)
}

func printResult(_ gameState : GameState,_ winner: Player?) {
    print()
    if (gameState == .resolved) {
        if (winner != nil) { print("\(winner!.getSymbol()) wins!") }
        else { print("Game ended in a draw") }
    }
    else { print("Game is still ongoing") }
    print()
}

func handleAi(_ game: Game, _ ai : MoveEvaluator ,_ player : Player) {
    game.board! = ai.getMove(ofBoard: game.board!, forPlayer: player)
}

func handleSetElement(_ game : Game,_ player : Player) {
    var row : Int?
    var column : Int?
    var input : Int?
    repeat {
        while (true) {
            print()
            print("Row : ", terminator : "")
            input = readNumber()
            if input == nil { continue }
            row = input!
            if !isProperIndex(value: row!, boardSize: game.boardSize) { continue }

            print("Column : ", terminator : "")
            input = readNumber()
            if input == nil { continue }
            column = input!
            if !isProperIndex(value: column!, boardSize: game.boardSize) { continue }
            break
        }
        print()
    } while !setElement(&game.board!, atPosition: (row!-1, column!-1), toPlayer: player)
}

func isProperIndex(value : Int, boardSize : Int) -> Bool {
    if (value < 1 || value > boardSize) {
        print("Input value exceeds board size")
        return false
    }
    return true
}

func setElement(_ board : inout Board, atPosition position : (Int,Int), toPlayer player: Player) -> Bool {
    do {
        try board.setElement(ofPlayer: player, toPosition: position)
        return true
    }
    catch {
        print("\(error)")
        return false
    }
}

func readNumber() -> Int? {
    let input = readLine()
    if Int(input!) != nil { return Int(input!)! }
    else {
        print("Input value must be an integer")
        return nil
    }
}

do {
    try playTicTacToe()
}
catch {
    print("\(error)")
}
