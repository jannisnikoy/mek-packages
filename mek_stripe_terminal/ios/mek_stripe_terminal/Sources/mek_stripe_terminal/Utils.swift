import Foundation

func createApiException(_ code: TerminalExceptionCodeApi, _ message: String? = nil) -> TerminalExceptionApi {
    return TerminalExceptionApi(
        code: code,
        message: message ?? "",
        stackTrace: nil,
        paymentIntent: nil,
        apiError: nil
 )
}

extension Optional {
    func apply(_ callback: (_ this: Wrapped) -> Any?) {
        if let this = self { callback(this) }
    }
}

extension Dictionary {
    func containsKey(_ key: Key) -> Bool {
        return contains(where: { entry in entry.key == key })
    }
}

extension Dictionary where Value: Equatable {
    func getKey(_ value: Value) -> Key? {
        return self.first(where: { k, v in v == value})?.key
    }
}

extension Int {
    func toInt64() -> Int64 {
        return Int64(self)
    }
}
extension UInt {
    func toInt64() -> Int64 {
        return Int64(self)
    }
    func toNsNumber() -> NSNumber {
        return NSNumber(value: self)
    }
}
extension Int64 {
    func toNsNumber() -> NSNumber {
        return NSNumber(value: self)
    }
    func toUInt() -> UInt {
        return UInt(self)
    }
    func toInt() -> Int {
        return Int(self)
    }
}
extension NSNumber {
    func toInt64() -> Int64 {
        return Int64(truncating: self)
    }
}

extension Date {
    func toMillisecondsSinceEpoch() -> Int64 {
        return Int64(timeIntervalSince1970 * 1000)
    }
}

extension PigeonEventSink {
    func addError(_ error: PigeonError) {
        self.error(code: error.code, message: error.message, details: error.details)
    }
}
