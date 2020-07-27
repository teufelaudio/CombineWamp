import Foundation

internal protocol ElementTypeConvertible: Codable {
    var asList: [ElementType] { get }
    static func from(list: [ElementType]) -> Self?
}

extension ElementTypeConvertible {
    internal init(from decoder: Decoder) throws {
        let list = try [ElementType].init(from: decoder)
        self = try Self.from(list: list) ?? { throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Can't parse list to \(Self.self)")) }()
    }

    internal func encode(to encoder: Encoder) throws {
        let list = asList
        try list.encode(to: encoder)
    }
}

internal enum ElementType: Equatable {
    case integer(Int)
    case string(String)
    case bool(Bool)
    case double(Double)
    indirect case dict([String: ElementType])
    indirect case list([ElementType])
}

extension ElementType {
    internal var integer: Int? {
        get {
            guard case let .integer(value) = self else { return nil }
            return value
        }
        set {
            guard case .integer = self, let newValue = newValue else { return }
            self = .integer(newValue)
        }
    }

    internal var string: String? {
        get {
            guard case let .string(value) = self else { return nil }
            return value
        }
        set {
            guard case .string = self, let newValue = newValue else { return }
            self = .string(newValue)
        }
    }

    internal var bool: Bool? {
        get {
            guard case let .bool(value) = self else { return nil }
            return value
        }
        set {
            guard case .bool = self, let newValue = newValue else { return }
            self = .bool(newValue)
        }
    }

    internal var double: Double? {
        get {
            guard case let .double(value) = self else { return nil }
            return value
        }
        set {
            guard case .double = self, let newValue = newValue else { return }
            self = .double(newValue)
        }
    }

    internal var dict: [String: ElementType]? {
        get {
            guard case let .dict(value) = self else { return nil }
            return value
        }
        set {
            guard case .dict = self, let newValue = newValue else { return }
            self = .dict(newValue)
        }
    }

    internal var list: [ElementType]? {
        get {
            guard case let .list(value) = self else { return nil }
            return value
        }
        set {
            guard case .list = self, let newValue = newValue else { return }
            self = .list(newValue)
        }
    }
}

extension ElementType: Codable {
    private struct AnyCodingKey: CodingKey {
        var stringValue: String

        init(stringValue: String) {
            self.stringValue = stringValue
        }

        var intValue: Int?
        init?(intValue: Int) {
            return nil
        }
    }

    internal init(from decoder: Decoder) throws {
        if var listContainer = try? decoder.unkeyedContainer() {
            var items: [ElementType] = []
            while !listContainer.isAtEnd {
                try items.append(listContainer.decode(ElementType.self))
            }
            self = .list(items)
            return
        }

        if let dictContainer = try? decoder.container(keyedBy: AnyCodingKey.self) {
            var items: [String: ElementType] = [:]
            try dictContainer.allKeys.forEach {
                items[$0.stringValue] = try dictContainer.decode(ElementType.self, forKey: $0)
            }

            self = .dict(items)
            return
        }

        let singleValueContainer = try decoder.singleValueContainer()

        if let integer = try? singleValueContainer.decode(Int.self) {
            self = .integer(integer)
            return
        }

        if let bool = try? singleValueContainer.decode(Bool.self) {
            self = .bool(bool)
            return
        }

        if let double = try? singleValueContainer.decode(Double.self) {
            self = .double(double)
            return
        }

        if let string = try? singleValueContainer.decode(String.self) {
            self = .string(string)
            return
        }

        throw DecodingError.dataCorruptedError(in: singleValueContainer, debugDescription: "Can't parse to any known type")
    }

    internal func encode(to encoder: Encoder) throws {
        switch self {
        case let .integer(integer):
            try integer.encode(to: encoder)
        case let .string(string):
            try string.encode(to: encoder)
        case let .bool(bool):
            try bool.encode(to: encoder)
        case let .double(double):
            try double.encode(to: encoder)
        case let .dict(dict):
            var container = encoder.container(keyedBy: AnyCodingKey.self)
            try dict.keys.forEach { key in
                try container.encode(dict[key], forKey: .init(stringValue: key))
            }
        case let .list(list):
            var container = encoder.unkeyedContainer()
            try list.forEach { item in
                try container.encode(item)
            }
        }
    }
}
