import Foundation

struct Board {
    unowned let game : Game
    var field : [[Player?]]
    let size : Int

    init(game : Game, ofSize size: Int) throws {
        self.game = game
        self.size = size
        self.field = [[Player?]]()

        if size < 1 {
            throw "Board size should be a positive integer"
        }
        for i in 0 ..< size {
            field.append([Player?]())
            for _ in 0..<size {
                field[i].append(nil)
            }
        }
    }

    func printBoard(withIndices includeIndices: Bool = false) {
        var rowIndex = 1
        var columnIndex = 1

        if includeIndices {
            print("\t", terminator : "")
            for index in field.indices {
                print("\t\(index+1)\t", terminator : "")
            }
            print()
        }

        for row in field {
            columnIndex = 1
            if includeIndices {
                print(" \(rowIndex)\t", terminator : "")
            }
            for element in row {
                print("\t\((element != nil) ? String(element!.getSymbol()) : " ")\t", terminator : "")
                if columnIndex != self.size {
                    print("||", terminator : "")
                }
                columnIndex += 1
            }
            if rowIndex != self.size {
                print()
                if includeIndices { print("\t ", terminator : "") }
                for _ in row.indices {
                    print("========", terminator : "")
                }
            }
            print()
            rowIndex += 1
        }
    }

    mutating func setElement(ofPlayer player : Player, toPosition position: (Int,Int)) throws {
        let (row,col) = position
        if getElement(position: position) != nil {
            throw "Given position is already occupied"
        }
        if (row < 0 || row >= field.count || col < 0 || col >= field.count) {
            throw "Given position exeeds board size"
        }
        self.field[row][col] = player
    }

    func getElement(position: (Int,Int)) -> Player? {
        let (row,col) = position
        return field[row][col]
    }

    func getOwner(atPosition position: (Int,Int)) -> Player? {
        let (row,col) = position
        if self.field[row][col] == nil { return nil }
        else {
            return self.field[row][col]!
        }
    }

    func getBoard() -> [[Player?]] {
        return self.field
    }

    func isEmpty() -> Bool {
        for row in field {
            for element in row {
                if (element !== nil) {
                    return false
                }
            }
        }
        return true
    }

    func getResult() -> (GameState,Player?) {
        var (rowState,rowWinner) : (GameState,Player?)
        var (columnState,columnWinner) : (GameState,Player?)
        var (diagonalState,diagonalWinner) : (GameState,Player?)

        (rowState,rowWinner) = checkRows()
        if (rowState == .resolved && rowWinner != nil) { return (.resolved,rowWinner) }

        (columnState,columnWinner) = checkColumns()
        if (columnState == .resolved && columnWinner != nil) { return (.resolved,columnWinner) }

        (diagonalState,diagonalWinner) = checkDiagonals()
        if (diagonalState == .resolved && diagonalWinner != nil) { return (.resolved,diagonalWinner) }
        if (rowState == .resolved) { return (.resolved, nil) }

        return (.pending, nil)
    }

    func checkColumns() -> (GameState,Player?) {
        var streak : Int = 0
        var currentPlayer : Player?
        var isAnyEmpty : Bool = false

        for col in 0 ... self.size-1 {
            streak = 0
            currentPlayer = field[0][col]
            for row in field {
                if (row[col] != nil) {
                    if (row[col]! === currentPlayer) {streak += 1}
                    else {
                        streak = 1
                        currentPlayer = row[col]!
                    }
                }
                else { streak = 0; isAnyEmpty = true }
                if (streak == game.winningValue) { return (.resolved, currentPlayer) }
            }
        }
        return isAnyEmpty ? (.pending,nil) : (.resolved,nil)
    }

    func checkRows() -> (GameState, Player?) {
        var streak : Int = 0
        var currentPlayer : Player?
        var isAnyEmpty : Bool = false

        for row in field {
            streak = 0
            currentPlayer = row[0]
            for item in row {
                if (item !== nil) {
                    if (item === currentPlayer) {streak += 1}
                    else {
                        streak = 1
                        currentPlayer = item
                    }
                }
                else { streak = 0; isAnyEmpty = true }
                if (streak == game.winningValue) { return (.resolved, currentPlayer) }
            }
        }
        return isAnyEmpty ? (.pending,nil) : (.resolved,nil)
    }

    func checkDiagonals() -> (GameState,Player?) {
        var leftStreak : Int = 0
        var rightStreak : Int = 0
        var currentLeftPlayer : Player?
        var currentRightPlayer : Player?

        var isAnyEmpty : Bool = false

        for i in game.winningValue-1 ... (2*size-1)-game.winningValue {

            currentLeftPlayer = getElement(position : (i >= size ? i%size+1 : 0, i >= size ? size-1 : i))
            currentRightPlayer = getElement(position : ((2*size-1)-i >= size ? ((2*size-1)-i)%size : 0, i < size ? 0 : i%(size-1)))
            leftStreak = 0
            rightStreak = 0

            for j in 0 ... size - abs(i-size+1) - 1 {

                // Left Side

                var row : Int, col : Int, item : Player?

                row = j+(i >= size ? i%size+1 : 0)
                col = (i >= size ? size-1 : i) - j
                item = getElement(position: (row,col))


                if (item != nil) {
                    if (item === currentLeftPlayer) {leftStreak += 1}
                    else {
                        leftStreak = 1
                        currentLeftPlayer = item
                    }
                }
                else { leftStreak = 0; isAnyEmpty = true }
                if (leftStreak == game.winningValue) { return (.resolved, currentLeftPlayer) }

                // Right side

                row = j+((2*size-1)-i >= size ? ((2*size-1)-i)%size : 0)
                col = (i < size ? 0 : i%(size-1)) + j
                item = getElement(position: (row,col))

                if (item != nil) {
                    if (item === currentRightPlayer) { rightStreak += 1}
                    else {
                        rightStreak = 1
                        currentRightPlayer = item
                    }
                }
                else { rightStreak = 0; isAnyEmpty = true }
                if ( rightStreak == game.winningValue) { return (.resolved, currentRightPlayer) }
            }
        }

        return isAnyEmpty ? (.pending,nil) : (.resolved,nil)
    }
}
