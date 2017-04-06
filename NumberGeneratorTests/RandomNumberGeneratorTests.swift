import XCTest

class RandomNumberGeneratorTests: XCTestCase {    
    func testNumberOfRandomNumbers() {
        let numbers = RandomNumberGenerator.generate(10, max: 100, min: 1, allowDuplicates: true)
        XCTAssertEqual(numbers.count, 10)
    }
    
    func testBoundsOfRandomNumbers() {
        let min = 23
        let max = 100
        let numbers = RandomNumberGenerator.generate(10000, max: max, min: min, allowDuplicates: true)
        let filteredNumbers = numbers.filter { return ($0 >= min && $0 <= max) }
        XCTAssertEqual(filteredNumbers.count, numbers.count)
    }
    
    func testDuplicatesOfRandomNumbers() {
        let numbers = RandomNumberGenerator.generate(100, max: 200, min: 1)
        let sortedNumbers = numbers.sorted(by: { return $0 < $1 })
        var previousNumber = 0
        for number in sortedNumbers {
            XCTAssertTrue(number != previousNumber)
            previousNumber = number
        }
    }
}
