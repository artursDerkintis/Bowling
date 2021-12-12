import Foundation

protocol FrameProtocol {

    /// Rolls pins
    func roll(pins: Int) throws

    /// Sets additional score from next roll after we hit strike in this frame
    /// - Parameter pins: Pins for the roll
    func setStrikeAdditionalScore(pins: Int)

    /// Sets additional score from next roll after we hit spare in this frame
    /// - Parameter pins: Pins for the roll
    func setSpareAdditionalScore(pins: Int)

    /// Throws error is there's too many pins
    func checkIfTooManyPins() throws


    /// Whether score is settled after all possible cases
    var isScoreSettled: Bool { get }

    /// Whether frame is tenth frame
    var isTenthFrame: Bool { get }

    /// Total score with additional spare/strike scores
    var score: Int { get }

    /// Is frame finished, meaning no rolls can be thrown
    var isFinished: Bool { get }

}

final class Frame {

    /// As per bowling rules there is 10 pins at max per each roll
    static let maxPinsCount = 10

    /// In normal frame you can roll up to 2 times
    private let maxRolls = 2

    /// In tenth frame you can roll up to 3 times if you hit a spare or strike in first two rolls
    private let maxRollsWithBonusRoll = 3

    /// After strike next 2 rolls counts towards the score of this frame
    private let maxStrikeNextRollCount = 2

    /// After spare next rolls counts towards the score of this frame
    private let maxSpareNextRollCount = 1

    /// Keeps track of additional score if we had hit strike
    private var strikeAdditionalScore = 0

    /// Keeps track of additional score if we had hit spare
    private var spareAdditionalScore = 0

    /// Keeps track of next rolls after hitting strike
    private var strikeNextRollCounter = 0

    /// Keeps track of next roll after hitting spare
    private var spareNextRollCounter = 0

    /// Store rolls in this frame
    private var rolls: [Int] = []

    /// If this frame is tenth frame
    public let isTenthFrame: Bool

    /// Keep track is score is settled after spare or strike additional scores have been added
    public var isScoreSettled = false


    /// Frame constructor
    /// - Parameter isTenthFrame: if the frame is tenth frame, based on what it will behave according to tenth frame rules
    init(isTenthFrame: Bool) {
        self.isTenthFrame = isTenthFrame
    }

    /// If frame can have bonus roll
    private var canHaveBonusRoll: Bool {
        isTenthFrame && (hasSpare || hasStrike)
    }

    /// Update isScoreSettled flag based on whether or not additional score have been calculated for spare or strike
    private func updateScoreIsSettled() {
        if hasSpare {
            isScoreSettled = spareNextRollCounter == maxSpareNextRollCount
        } else if hasStrike {
            isScoreSettled = strikeNextRollCounter == maxStrikeNextRollCount
        } else {
            isScoreSettled = true
        }
    }

    /// Has spare in first 2 rolls
    private var hasSpare: Bool {
        guard rolls.count > 1 else { return false }
        return rolls.prefix(2).reduce(0, +) == Frame.maxPinsCount
    }

    /// Has strike in any of the rolls
    private var hasStrike: Bool {
        rolls.contains(where: { $0 == Frame.maxPinsCount })
    }

    /// Overall rolls score (without additions of next rolls for spare/strike)
    private var rollsScore: Int {
        rolls.reduce(0, +)
    }

    /// Throws error if there's too many or too little pins in roll
    /// - Parameter pins: Pins in roll
    private func checkIfInvalidPinsPerRoll(pins: Int) throws {
        guard pins > Frame.maxPinsCount || pins < 0 else { return }
        throw BowlingError.invalidNumberOfPins
    }

    /// Has rolled bonus roll
    private var hasRolledBonusRoll: Bool { rolls.count == maxRollsWithBonusRoll }


    /// Last two rolls have too many pins
    private var lastTwoRollsHasTooManyPins: Bool { rolls.suffix(2).reduce(0, +) > Frame.maxPinsCount }

}

extension Frame: FrameProtocol {
    
    func checkIfTooManyPins() throws {
        guard isTenthFrame else {
            guard rollsScore > Frame.maxPinsCount else { return }
            throw BowlingError.tooManyPinsInFrame
        }
        guard hasRolledBonusRoll && hasStrike && lastTwoRollsHasTooManyPins else {
            if !hasStrike {
                guard lastTwoRollsHasTooManyPins else { return }
                throw BowlingError.tooManyPinsInFrame
            }
            return
        }
        throw BowlingError.tooManyPinsInFrame
    }


    func setSpareAdditionalScore(pins: Int) {
        guard hasSpare else { return }

        guard spareNextRollCounter < maxSpareNextRollCount else { return }

        spareNextRollCounter += 1

        spareAdditionalScore += pins

        updateScoreIsSettled()
    }

    func setStrikeAdditionalScore(pins: Int) {
        guard hasStrike else { return }

        guard strikeNextRollCounter < maxStrikeNextRollCount else { return }

        strikeNextRollCounter += 1

        strikeAdditionalScore += pins

        updateScoreIsSettled()
    }

    func roll(pins: Int) throws {
        try checkIfInvalidPinsPerRoll(pins: pins)
        rolls.append(pins)

        updateScoreIsSettled()
    }

    var score: Int {
        rollsScore + strikeAdditionalScore + spareAdditionalScore
    }

    var isFinished: Bool {

        if hasStrike && !isTenthFrame { return true }

        if canHaveBonusRoll {
            return rolls.count == maxRollsWithBonusRoll
        }

        return rolls.count == maxRolls
    }

}
