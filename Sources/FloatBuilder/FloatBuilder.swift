import Foundation

public struct FloatBuilder {
	public let sign: FloatingPointSign
	public let exponent: [Bool]
	public let mantissa: [Bool]
	let impliedIntegerBit: Bool

	public var exponentValue: Int {
		let biasA = 0b1 << (exponent.count - 1)
		let biasB = biasA - 1

		var biasedExp = 0
		for (index, bit) in exponent.reversed().enumerated() {
			biasedExp |= (bit ? 0b1 : 0b0) << index
		}

		return biasedExp - biasB
	}

	public var bits: Int {
		exponent.count + mantissa.count + 1 + (impliedIntegerBit ? 0 : 1)
	}

	enum FloatComponentError: Error {
		case mismatchDataAndExpectedBits
	}

	public init(data: [UInt8], exponentBitCount: Int, mantissaBitCount: Int, impliedIntegerBit: Bool = true) throws {
		let totalBits = exponentBitCount + mantissaBitCount + 1 + (impliedIntegerBit ? 0 : 1)
		self.impliedIntegerBit = impliedIntegerBit
		guard data.count * 8 == totalBits else { throw FloatComponentError.mismatchDataAndExpectedBits }

		self.sign = data[bitOffset: 0, bitOrder: .mostToLeastSignificant] == true ? .minus : .plus

		var exponent: [Bool] = []
		for i in stride(from: 1, to: exponentBitCount + 1, by: 1) {
			exponent.append(data[bitOffset: i, bitOrder: .mtl])
		}
		self.exponent = exponent

		var mantissa: [Bool] = []
		let offset = 1 + (impliedIntegerBit ? 0 : 1)
		for i in stride(from: exponentBitCount + offset, to: totalBits, by: 1) {
			mantissa.append(data[bitOffset: i, bitOrder: .mtl])
		}
		self.mantissa = mantissa
	}

	private func split() -> (whole: [Bool], fraction: [Bool]) {
		let adjustedMantissa = [true] + mantissa
		let exp = exponentValue + 1

		let completeMantissa: [Bool]
		if exp > 0 {
			if exp > adjustedMantissa.count {
				let padding = Array(repeating: false, count: exp - adjustedMantissa.count)
				completeMantissa = adjustedMantissa + padding
			} else {
				completeMantissa = adjustedMantissa
			}

			return (Array(completeMantissa[0..<exp]), Array(completeMantissa[exp...]))
		} else {
			let absExp = abs(exp)
			let padding = Array(repeating: false, count: absExp)
			completeMantissa = padding + adjustedMantissa

			return ([], completeMantissa)
		}
	}

	func decimalValue() -> Decimal {
		let (whole, fraction) = split()

		var output = Decimal(0)
		for (offset, bit) in whole.reversed().enumerated() where bit {
			let twosPlace = pow(Decimal(2), offset)
			output += twosPlace
		}

		for (offset, bit) in fraction.enumerated() where bit {
			let decimalPlace = 1 / (pow(Decimal(2), offset + 1))
			output += decimalPlace
		}

		if sign == .minus { output *= -1 }
		return output
	}
}
