protocol BowlingProtocol {

    /// Rolls the pins
    func roll(pins: Int) throws

    ///  Totals game score
    /// - Returns: Score from all frames
    func score() throws -> Int
}

final class Bowling {

    /// As per bowling rules there is 10 frames
    static let maxFrameCount = 10

    /// Keeps track of current frame index
    private var currentFrameIndex = 0

    /// Array of all frames
    private let frames: [FrameProtocol]
    init(frames: [FrameProtocol] = (0..<Bowling.maxFrameCount).map { index in Frame(isTenthFrame: index == Bowling.maxFrameCount - 1) }) {
        self.frames = frames
    }

    /// Returns current frame in progress
    private var currentFrame: FrameProtocol {
        guard frames.indices.contains(currentFrameIndex) else {
            fatalError("Frames at \(currentFrameIndex) not found")
        }
        return frames[currentFrameIndex]
    }

    /// Throws error if game is in progress
    private func checkIfGameIsInProgress() throws {
        guard !currentFrame.isFinished else { return }
        throw BowlingError.gameInProgress
    }

    /// Throws error if game is over
    private func checkIfGameIsOver() throws {
        guard frames.filter({ $0.isFinished }).count == Bowling.maxFrameCount else { return }
        throw BowlingError.gameIsOver
    }

    /// Handles the pins rolled
    /// - Parameter pins: Pins for roll
    private func handlePins(pins: Int) throws {
        updatePreviousFramesAfterSpareOrStrike(pins: pins)

        try currentFrame.roll(pins: pins)

        try currentFrame.checkIfTooManyPins()

        setCurrentFrameIndex()
    }

    /// Goes over previous frames and updates their additional scores if they had strike/spare
    /// - Parameter pins: Pins for roll
    private func updatePreviousFramesAfterSpareOrStrike(pins: Int) {
        frames.forEach { frame in
            guard frame.isFinished && !frame.isScoreSettled else { return }
            frame.setSpareAdditionalScore(pins: pins)
            frame.setStrikeAdditionalScore(pins: pins)
        }
    }

    /// Set current frame index if current frame is finished
    private func setCurrentFrameIndex() {
        guard !currentFrame.isTenthFrame && currentFrame.isFinished else { return }
        currentFrameIndex += 1
    }

}

extension Bowling: BowlingProtocol {

    func roll(pins: Int) throws {
        try checkIfGameIsOver()
        try handlePins(pins: pins)
    }

    func score() throws -> Int {
        try checkIfGameIsInProgress()
        return frames.map { $0.score }.reduce(0, +)
    }
}
