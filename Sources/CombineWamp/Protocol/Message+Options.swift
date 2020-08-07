import Foundation

extension Dictionary where Key == String, Value == ElementType {
    public static var acknowledge: [String: ElementType] {
        ["acknowledge": .bool(true)]
    }
}
