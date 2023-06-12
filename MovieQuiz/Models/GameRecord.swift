import Foundation

struct GameRecord: Comparable, Codable {
    let correct: Int
    let total: Int
    let date: Date
    static func <(lhs: GameRecord, rhs: GameRecord) -> Bool {
        return lhs.correct < rhs.correct
    }
}
