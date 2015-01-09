// Created by Vladimir Magaziy <vmagaziy@gmail.com>

import Foundation

class RandomNumberGenerator {
    class func generateWithCount(count: UInt, max: UInt, min: UInt, allowDuplicates: Bool) -> [UInt] {
        assert(count > 0 && max > min, "Invalid parameters")
        assert(allowDuplicates || count < max - min, "Invalid parameters")
        var randomNumbers: [UInt] = []
        
        var numbersSet: NSMutableSet!
        if !allowDuplicates { 
            numbersSet = NSMutableSet(capacity: Int(count))
        }
        
        while (UInt(randomNumbers.count) != count) {
            var randomNumber = UInt(arc4random_uniform(UInt32(max - min))) + min;
            if !allowDuplicates && numbersSet.containsObject(randomNumber) {
                continue
            }
            
            randomNumbers.append(randomNumber)
            numbersSet?.addObject(randomNumber)
        }
        
        return randomNumbers
    }
}
