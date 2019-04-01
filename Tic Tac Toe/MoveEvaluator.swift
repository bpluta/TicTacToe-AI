import Foundation

enum MinMax {
    case min, max
}

class MoveEvaluator {
    let game : Game
    let offensiveEvaluator : StreakEvaluator
    let deffensiveEvaluator : StreakEvaluator
    let finalDeffensiveEvaluator : StreakEvaluator
    let players : [Player]
    let radius : Int
    let searchDepth : Int

    init(_ game : Game,_ offensiveValue : Int,_ deffensiveValue : Int,_ searchDepth : Int = 3,_ radius : Int = 1) {
        self.game = game
        self.offensiveEvaluator = StreakEvaluator(baseValue: offensiveValue, winningValue: game.winningValue)
        self.deffensiveEvaluator = StreakEvaluator(baseValue: deffensiveValue, winningValue: game.winningValue-1)
        self.finalDeffensiveEvaluator = StreakEvaluator(baseValue: deffensiveValue, winningValue: game.winningValue)
        self.players = self.game.players

        self.radius = radius
        self.searchDepth = searchDepth
    }

    func getMove(ofBoard board : Board, forPlayer player : Player) -> Board {
        if board.isEmpty() {
            var bestBoard = board
            getInitialState(board: &bestBoard, player: player)
            return bestBoard
        }

        let (bestBoard,_,_) = alphaBeta(node: board, self.searchDepth, Int.min, Int.max, type: .max , player: player, currentPlayer: player, 0)
        return bestBoard
    }

    func alphaBeta(node : Board, _ depth : Int, _ alpha : Int, _ beta : Int, type : MinMax, player : Player, currentPlayer : Player, _ currentDepth : Int) -> (Board,Int,Int) {
        let (result,winner) = node.getResult()
        if depth == 0 {
            var score : Int
            if result == .resolved {
                if (winner !== nil) {
                    score = evaluateMoveValue(board: node, player: player, isFinal : true)
                    if (winner === player) {
                        return (node, score/(currentDepth+1), currentDepth)
                    }
                    else {
                        return (node, score/(currentDepth), currentDepth)
                    }
                }
            }
            else {
                score = evaluateMoveValue(board: node, player: player)
                if (score == Int.min) {
                    score /= currentDepth
                }
                return (node, score, currentDepth)
            }
        }

        if (result == .resolved) {
            if (winner != nil) {
                if (winner! === player) {
                    return (node, Int.max/(currentDepth+1), currentDepth)
                }
                else {
                    return (node, Int.min/(currentDepth), currentDepth)
                }
            }
            else {
                return (node, evaluateMoveValue(board: node, player: player, isFinal : true), currentDepth)
            }
        }
        return evaluateNodeValue(node : node, depth, alpha, beta, type : type,player : player, currentPlayer : currentPlayer, currentDepth)
    }

    func evaluateNodeValue(node : Board, _ depth : Int, _ alpha : Int, _ beta : Int, type : MinMax, player : Player, currentPlayer : Player, _ currentDepth : Int) -> (Board,Int,Int) {

        let surrounding = getSurrounding(board: node, radius: radius)

        var newAlpha = alpha
        var newBeta = beta

        var bestBoard : Board?
        var bestResult : Int = type == .max ? Int.min : Int.max
        var bestBoardDepth : Int = type == .max ? Int.max : Int.min

        var foundBetterMove : Bool = false

        for freePosition in surrounding {

            var move = node
            try! move.setElement(ofPlayer: currentPlayer, toPosition: freePosition)

            let (_,currentBoardResult,currentBoardDepth) = self.alphaBeta(node: move, depth-1, newAlpha, newBeta, type: type == .max ? .min : .max, player: player, currentPlayer: self.getOpponent(forPlayer: currentPlayer), currentDepth+1)

            bestBoard = bestBoard ?? move

            if (type == .max) {
                foundBetterMove = bestResult <= currentBoardResult ? true : false
            }
            else if (type == .min) {
                foundBetterMove = bestResult >= currentBoardResult ? true : false
            }

            if (foundBetterMove) {
                bestResult = currentBoardResult
                bestBoard = move
                bestBoardDepth = currentBoardDepth
            }

            if (type == .max) { newAlpha = max(newAlpha, bestResult) }
            else if (type == .min) { newBeta = min(newBeta, bestResult) }

            if (newAlpha > newBeta) { break }
        }

        return (bestBoard!, bestResult, bestBoardDepth)
    }

    func getSurrounding(board : Board, radius : Int) -> [(Int, Int)] {
        var surroundings = [(Int,Int)]()

        for i in 0 ... board.size-1 {
            for j in 0 ... board.size-1 {
                guard let foundSurrounding = getFieldSurrounding(position: (i, j), radius, board) else {
                    continue
                }
                for (row,col) in foundSurrounding {
                    if !surroundings.contains(where: { $0.0 == row && $0.1 == col }) {
                        surroundings.append((row,col))
                    }
                }
            }
        }
        return surroundings
    }

    func getFieldSurrounding(position : (Int, Int), _ radius : Int, _ board : Board) -> [(Int,Int)]? {
        let (row, col) = position
        if board.getElement(position: (row,col)) == nil {
            return nil
        }
        var surrounding = [(Int,Int)]()

        for rowOffset in -radius ... radius {
            for colOffset in -radius ... radius {
                if (row+rowOffset >= 0 && row+rowOffset < board.size) {
                    if (col+colOffset >= 0 && col+colOffset < board.size) {
                        if ((colOffset != 0) || (rowOffset != 0)) {
                            if (board.getElement(position: (row+rowOffset , col+colOffset)) == nil) {
                                surrounding.append((row+rowOffset , col+colOffset))
                            }
                        }
                    }
                }
            }
        }
        return surrounding
    }

    func getInitialState(board: inout Board, player : Player) {
        let index = board.field.count/2
        try! board.setElement(ofPlayer: player, toPosition: (index, index))
    }

    func evaluateMoveValue(board : Board, player : Player, isFinal : Bool = false) -> Int {
        let offensiveValue = offensiveEvaluator.getBoardPayoff(board: board, player: player)
        let deffensiveValue = isFinal ? finalDeffensiveEvaluator.getBoardPayoff(board: board, player: getOpponent(forPlayer: player)) : deffensiveEvaluator.getBoardPayoff(board: board, player: getOpponent(forPlayer: player))

        if (offensiveValue == Int.max) { return Int.max }
        if (deffensiveValue == Int.max) { return Int.min }

        return offensiveValue - deffensiveValue
    }

    func getOpponent(forPlayer player : Player) -> Player {
        if (player === self.players[0]) {
            return self.players[1]
        }
        else  { return self.players[0] }
    }
}
