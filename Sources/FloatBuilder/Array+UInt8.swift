import Foundation

extension Array where Element == UInt8 {
	var bitCount: Int { count * 8 }

	private func valueAt(index: Int) -> UInt8 {
		self[index]
	}

	subscript(bitOffset bitOffset: Int, bitOrder bitOrder: UInt8.BitOrder = .leastToMostSignificant) -> Bool {
		get {
			let byteIndex = bitOffset / 8
			let bit = bitOffset % 8

			let theByte = self[byteIndex]
			return theByte[bit, bitOrder: bitOrder]
		}

		set {
			let byteIndex = bitOffset / 8
			let bit = bitOffset % 8

			self[byteIndex][bit, bitOrder: bitOrder] = newValue
		}
	}
}
