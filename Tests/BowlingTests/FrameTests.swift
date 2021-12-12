import XCTest
@testable import Bowling

final class FrameTests: XCTestCase {

    var frame: Frame!

    func testCanSetStrikeBonusScoreTwice() {
        frame = Frame(isTenthFrame: false)

        try? frame.roll(pins: 10)

        frame.setStrikeAdditionalScore(pins: 5)
        frame.setStrikeAdditionalScore(pins: 1)
        frame.setStrikeAdditionalScore(pins: 5)

        XCTAssertEqual(frame.score, 16)
    }

    func testCannotSetStrikeBonusScoreWhenNoStrike() {
        frame = Frame(isTenthFrame: false)

        try? frame.roll(pins: 0)
        try? frame.roll(pins: 0)

        frame.setStrikeAdditionalScore(pins: 5)
        frame.setStrikeAdditionalScore(pins: 1)

        XCTAssertEqual(frame.score, 0)
    }

    func testCanSetSpareBonusScoreOnce() {
        frame = Frame(isTenthFrame: false)

        try? frame.roll(pins: 7)
        try? frame.roll(pins: 3)

        frame.setSpareAdditionalScore(pins: 5)
        frame.setSpareAdditionalScore(pins: 1)

        XCTAssertEqual(frame.score, 15)
    }

    func testCannotSetSpareBonusScoreWhenNoSpare() {
        frame = Frame(isTenthFrame: false)

        try? frame.roll(pins: 1)
        try? frame.roll(pins: 6)

        frame.setSpareAdditionalScore(pins: 5)
        frame.setSpareAdditionalScore(pins: 1)

        XCTAssertEqual(frame.score, 7)
    }

    func testScoreIsSettledWhenSpareBonusIsSet() {
        frame = Frame(isTenthFrame: false)

        try? frame.roll(pins: 7)
        try? frame.roll(pins: 3)

        frame.setSpareAdditionalScore(pins: 5)

        XCTAssertEqual(frame.isScoreSettled, true)
    }

    func testScoreIsNotSettledWhenSpareBonusIsNotSet() {
        frame = Frame(isTenthFrame: false)

        try? frame.roll(pins: 7)
        try? frame.roll(pins: 3)

        XCTAssertEqual(frame.isScoreSettled, false)
    }

    func testScoreIsSettledWhenStrikeBonusIsSet() {
        frame = Frame(isTenthFrame: false)

        try? frame.roll(pins: 10)

        frame.setStrikeAdditionalScore(pins: 5)
        frame.setStrikeAdditionalScore(pins: 1)

        XCTAssertEqual(frame.isScoreSettled, true)
    }

    func testScoreIsNotSettledWhenStrikeBonusIsNotSet() {
        frame = Frame(isTenthFrame: false)

        try? frame.roll(pins: 10)

        frame.setStrikeAdditionalScore(pins: 5)

        XCTAssertEqual(frame.isScoreSettled, false)
    }

    func testIsNotFinishedWhenStrikeOnFirstRollOfTenthFrame() {
        frame = Frame(isTenthFrame: true)

        try? frame.roll(pins: 10)
        try? frame.roll(pins: 1)

        XCTAssertEqual(frame.isFinished, false)
    }

    func testIsNotFinishedWhenSpareOfTenthFrame() {
        frame = Frame(isTenthFrame: true)

        try? frame.roll(pins: 7)
        try? frame.roll(pins: 3)

        XCTAssertEqual(frame.isFinished, false)
    }

    func testIsFinishedWhenOpenFrameOfTenthFrame() {
        frame = Frame(isTenthFrame: true)

        try? frame.roll(pins: 1)
        try? frame.roll(pins: 1)

        XCTAssertEqual(frame.isFinished, true)
    }

    func testIsFinishedWhenStrike() {
        frame = Frame(isTenthFrame: false)

        try? frame.roll(pins: 10)

        XCTAssertEqual(frame.isFinished, true)
    }

    func testIsNotFinishedWhenNotStrikeOnFirstRoll() {
        frame = Frame(isTenthFrame: false)

        try? frame.roll(pins: 0)

        XCTAssertEqual(frame.isFinished, false)
    }

    func testIsFinishedWhenBothRollsRolled() {
        frame = Frame(isTenthFrame: false)

        try? frame.roll(pins: 0)
        try? frame.roll(pins: 0)

        XCTAssertEqual(frame.isFinished, true)
    }
}
