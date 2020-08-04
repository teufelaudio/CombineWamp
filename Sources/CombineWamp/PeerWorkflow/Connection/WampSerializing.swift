import Foundation

public struct WampSerializing {
    public init(serializationFormat: URI.SerializationFormat, serialize: @escaping (Message) -> Result<String, Error>, deserialize: @escaping (String) -> Result<Message, Error>) {
        self.serializationFormat = serializationFormat
        self.serialize = serialize
        self.deserialize = deserialize
    }

    public let serializationFormat: URI.SerializationFormat
    public let serialize: (Message) -> Result<String, Error>
    public let deserialize: (String) -> Result<Message, Error>
}

extension WampSerializing {
    public static func json(decoder: @escaping () -> JSONDecoder, encoder: @escaping () -> JSONEncoder) -> WampSerializing {
        WampSerializing(
            serializationFormat: URI.SerializationFormat.json,
            serialize: { message in
                Result {
                    try String(data: encoder().encode(message), encoding: .utf8)
                        ?? { throw EncodingError.invalidValue(message, EncodingError.Context.init(codingPath: [], debugDescription: "Invalid UTF8 String")) }()
                }
            },
            deserialize: { string in
                Result {
                    try string.data(using: .utf8).map { data in
                        try decoder().decode(Message.self, from: data)
                    }
                    ?? { throw DecodingError.dataCorrupted(DecodingError.Context.init(codingPath: [], debugDescription: "Invalid UTF8 String")) }()
                }
            }
        )
    }
}
