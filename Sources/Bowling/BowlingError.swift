import Foundation

enum BowlingError: Error {
    case invalidNumberOfPins
    case tooManyPinsInFrame
    case gameInProgress
    case gameIsOver
}
