import Foundation

class StreakEvaluator {
    let winningValue : Int
    let baseValue : Int

    init(baseValue : Int, winningValue : Int) {
        self.winningValue = winningValue
        self.baseValue = baseValue
    }

    func getBestStreakFromTheLeft(_ player : Player, _ row : [Player?]) -> Int {
        var pos = 0
        var maxStreak = 0
        var maxStreakPosition = 0

        while pos <= row.count - winningValue {
            var currentStreak = 0
            for i in 0 ... winningValue-1 {
                let current = row[pos+i]
                if (current !== player && current !== nil) { currentStreak = 0; pos += 1; break }
                if current === player {
                    currentStreak += 1
                }
            }

            if (currentStreak == winningValue) { return Int.max }

            if (currentStreak > maxStreak) {
                maxStreak = currentStreak
                maxStreakPosition = pos
            }
            pos += 1
        }

        if (maxStreak > 0) {
            var leftPosition = maxStreakPosition + winningValue - 1
            var rightPosition = maxStreakPosition

            for _ in 0 ... winningValue-1 {
                if row[rightPosition] === player { break }
                rightPosition += 1
            }

            for _ in 0 ... winningValue-1 {
                if row[leftPosition] === player { break }
                leftPosition -= 1
            }

            let leftArray = Array(row[..<leftPosition])
            let rightArray = Array(row[(rightPosition+1)...])

            var leftArrayValue = 0
            var rightArrayValue = 0

            if (leftArray.count >= winningValue) {
                leftArrayValue = getBestStreakFromTheRight(player, leftArray)
                if leftArrayValue == Int.max { return Int.max }
            }
            if (rightArray.count >= winningValue) {
                rightArrayValue = getBestStreakFromTheLeft(player, rightArray)
                if rightArrayValue == Int.max { return Int.max}
            }

            return getPoints(maxStreak) + leftArrayValue + rightArrayValue
        }
        else { return 0 }
    }

    func getBestStreakFromTheRight(_ player : Player, _ row : [Player?]) -> Int {
        var pos = row.count - 1
        var maxStreak = 0
        var maxStreakPosition = 0

        while pos >= winningValue - 1 {
            var currentStreak = 0
            for i in 0 ... winningValue-1 {
                let current = row[pos-i]
                if (current !== player && current !== nil) { currentStreak = 0; pos -= 1; break }
                if current === player {
                    currentStreak += 1
                }
            }
            if (currentStreak == winningValue) { return Int.max }

            if (currentStreak > maxStreak) {
                maxStreak = currentStreak
                maxStreakPosition = pos
            }
            pos -= 1
        }

        if (maxStreak > 0) {
            var leftPosition = maxStreakPosition - winningValue + 1
            var rightPosition = maxStreakPosition

            for _ in 0 ... winningValue-1 {
                if row[rightPosition] === player { break }
                rightPosition -= 1
            }

            for _ in 0 ... winningValue-1 {
                if row[leftPosition] === player { break }
                leftPosition += 1
            }

            let leftArray = Array(row[..<rightPosition])
            let rightArray = Array(row[(leftPosition+1)...])

            var leftArrayValue = 0
            var rightArrayValue = 0

            if (leftArray.count >= winningValue) {
                leftArrayValue = getBestStreakFromTheRight(player, leftArray)
                if leftArrayValue == Int.max { return Int.max }
            }
            if (rightArray.count >= winningValue) {
                rightArrayValue = getBestStreakFromTheLeft(player, rightArray)
                if rightArrayValue == Int.max { return Int.max}
            }

            return getPoints(maxStreak) + leftArrayValue + rightArrayValue

        }
        else { return 0 }
    }

    func getHorizontalPayoff(_ board : Board, _ player : Player) -> Int {
        var result = 0

        for horizontalRow in board.getBoard() {
            let currentResult = getBestStreakFromTheLeft(player, horizontalRow)
            if (currentResult == Int.max) { return currentResult }
            result += currentResult
        }
        return result
    }

    func getVerticalPayOff(_ board : Board, _ player : Player) -> Int {
        var result = 0

        for col in 0 ... board.size - 1 {
            var verticalRow = [Player?]()
            for row in 0 ... board.size - 1 {
                verticalRow.append(board.getElement(position: (row, col)))
            }
            let currentResult = getBestStreakFromTheLeft(player, verticalRow)
            if (currentResult == Int.max) { return currentResult }
            result += currentResult
        }
        return result
    }

    func getDiagonalPayoff(_ board : Board, _ player : Player) -> Int {
        var result = 0

        for i in winningValue-1 ... ((2*board.size)-1)-winningValue {
            var leftRow =  [Player?]()
            var rightRow = [Player?]()

            for j in 0 ... board.size - abs(i - board.size + 1) - 1 {
                var row : Int, col : Int

                // Left Side

                row = j+(i >= board.size ? i%board.size+1 : 0)
                col = (i >= board.size ? board.size-1 : i) - j
                leftRow.append(board.getElement(position: (row, col)))

                // Right side

                row = j+((2*board.size-1)-i >= board.size ? ((2*board.size-1)-i)%board.size : 0)
                col = (i < board.size ? 0 : i%(board.size-1)) + j
                rightRow.append(board.getElement(position: (row, col)))
            }
            let currentLeftResult = getBestStreakFromTheLeft(player, leftRow)
            let currentRightResult = getBestStreakFromTheLeft(player, rightRow)

            if (currentLeftResult == Int.max) { return currentLeftResult }
            if (currentRightResult == Int.max) { return currentRightResult }

            result += currentLeftResult
            result += currentRightResult
        }

        return result
    }

    func getPoints(_ streak : Int) -> Int {
        return Int(pow(Double(self.baseValue),Double(streak-1)))
    }

    func getBoardPayoff(board : Board, player : Player) -> Int {
        var result = 0
        var currentResult = getHorizontalPayoff(board, player)
        if (currentResult == Int.max) { return Int.max }
        else { result += currentResult }

        currentResult = getVerticalPayOff(board, player)
        if (currentResult == Int.max) { return Int.max }
        else { result += currentResult }

        currentResult = getDiagonalPayoff(board,player)
        if (currentResult == Int.max) { return Int.max }
        else { result += currentResult }

        return result
    }
}
