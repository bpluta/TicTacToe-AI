import Foundation

class Player {
    let id : Int
    var symbol : Character

    init(playerID id : Int, playerSymbol symbol : Character) {
        self.id = id
        self.symbol = symbol
    }

    func getID() -> Int {
        return self.id
    }

    func getSymbol() -> Character {
        return self.symbol
    }

    func getPlayer() -> Player {
        return self
    }
}
