import Foundation

extension BinaryInteger {
	//FIXME: this is partially correct and partially incorrect - come up with better
	/// The bytes naturally fall into place where the lower the index of the array, the less significant the byte is. This effectively makes this byte array ordered in little
	/// endian, when written out in the array from left to right. If you pass `true` for `bigEndian`, the byte order will be reversed, so the most significant byte
	/// will be at the lowest index, but reading the bytes from left to right will appear to be the natural order
	func toBytes(bigEndian: Bool = false) -> [UInt8] {
		let byteCount = MemoryLayout<Self>.size
		let pointer = UnsafeMutablePointer<Self>.allocate(capacity: 1)
		pointer[0] = self
		let rawBytes = UnsafeMutableRawPointer(pointer)

		let output = (0..<byteCount).map {
			rawBytes.load(fromByteOffset: $0, as: UInt8.self)
		}

		pointer.deallocate()
		return bigEndian ? output.reversed() : output
	}
}
