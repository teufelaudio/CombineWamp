extension Dictionary: ElementTypeConvertible where Key == String, Value == ElementType {
    public var asList: [ElementType] {
        return [.dict(self)]
    }

    public static func from(list: [ElementType]) -> Self? {
        list.first?.dict
    }
}
