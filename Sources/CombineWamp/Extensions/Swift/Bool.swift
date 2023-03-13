extension Bool: ElementTypeConvertible {
    public var asList: [ElementType] {
        [.bool(self)]
    }

    public static func from(list: [ElementType]) -> Self? {
        list.first?.bool
    }
}
