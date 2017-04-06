import Foundation

class RandomNumberGenerator {
    class func generate(_ count: Int, max: Int = Int.max, min: Int = 0, allowDuplicates: Bool = false) -> [Int] {
        assert(count > 0 && max > min, "Invalid parameters")
        assert(allowDuplicates || count < max - min, "Invalid parameters")
        var numbers: [Int] = []
        var numbersCount = 0
        
        while (numbersCount != count) {
            let number = Int(arc4random_uniform(UInt32(max - min))) + min
            // skip dups in requested
            // todo: use a set to check dups in O(1)
            if !allowDuplicates && numbers.contains(number) {
                continue
            }
            
            numbers.append(number)
            numbersCount += 1
        }
        
        return numbers
    }
}
