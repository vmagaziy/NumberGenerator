// Created by Vladimir Magaziy <vmagaziy@gmail.com>

import Foundation

class RandomNumberGenerator {
    class func generateWithCount(count: UInt, max: UInt, min: UInt) -> [UInt] {
        assert(count > 0 && max > min, "Invalid parameters")
        var randomNumbers: [UInt] = []
        for i in 0...count - 1 {
            var number = UInt(arc4random_uniform(UInt32(max - min))) + min;
            randomNumbers.append(number)
        }
        
        return randomNumbers
    }
}
