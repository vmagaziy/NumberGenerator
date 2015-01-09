// Created by Vladimir Magaziy <vmagaziy@gmail.com>

import UIKit
import XCTest

class RandomNumberGeneratorTests: XCTestCase {    
    func testNumberOfRandomNumbers() {
        let numbers = RandomNumberGenerator.generateWithCount(10, max:100, min:1, allowDuplicates: true)
        XCTAssertEqual(numbers.count, 10, "")
    }
    
    func testBoundsOfRandomNumbers() {
        let min: UInt = 23
        let max: UInt = 100
        let numbers = RandomNumberGenerator.generateWithCount(10000, max:max, min:min, allowDuplicates: true)
        for number in numbers {
            XCTAssertTrue(number >= min && number <= max, "")
        }
    }
    
    func testDuplicatesOfRandomNumbers() {
        let numbers = RandomNumberGenerator.generateWithCount(100, max:200, min:1, allowDuplicates: false)
        let sortedNumbers = numbers.sorted(<)
        var previousNumber: UInt = 0
        for number in sortedNumbers {
            XCTAssertTrue(number != previousNumber, "")
            previousNumber = number
        }
    }
}
