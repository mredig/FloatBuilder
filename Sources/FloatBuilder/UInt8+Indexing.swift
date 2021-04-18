import Foundation

extension UInt8: RandomAccessCollection {
	public func index(after i: Int) -> Int { i + 1 }

	public var startIndex: Int { 0 }

	public var endIndex: Int { MemoryLayout<Self>.size * 8 }

	public enum BitOrder {
		case leastToMostSignificant
		case mostToLeastSignificant

		static public let mtl = Self.mostToLeastSignificant
		static public let ltm = Self.leastToMostSignificant
	}

	/// Within each byte, each bit can be accessed via indicies in least to most significant (`76543210`) or most to least significant (`01234567`). Indicies outside
	/// `0..<8` result in a false value
	public subscript(index: Int, bitOrder bitOrder: BitOrder = .ltm) -> Bool {
		get {
			var index = index
			if bitOrder == .mostToLeastSignificant {
				index = 7 - index
			}
			return (self >> index) & 0b1 == 1
		}

		set {
			var index = index
			if bitOrder == .mostToLeastSignificant {
				index = 7 - index
			}
			let bitVal: UInt8 = 0b1 << index
			if newValue {
				self |= bitVal
			} else {
				self ^= bitVal
			}
		}
	}

	public subscript(index: Int) -> Bool {
		get {
			self[index, bitOrder: .leastToMostSignificant]
		}

		set {
			self[index, bitOrder: .leastToMostSignificant] = newValue
		}
	}


	func toBinaryString() -> String {
		let string = String(self, radix: 2)
		let zeroes = String(repeating: "0", count: 8 - string.count)
		return "\(zeroes)\(string)"
	}

	var binaryString: String { toBinaryString() }

	func toHexString() -> String {
		let string = String(self, radix: 16)
		let zeroes = String(repeating: "0", count: 2 - string.count)
		return "\(zeroes)\(string)"
	}

	var hexString: String { toHexString() }
}

