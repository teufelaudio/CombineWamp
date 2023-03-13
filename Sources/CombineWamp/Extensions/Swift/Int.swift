extension Int: ElementTypeConvertible {
    public var asList: [ElementType] {
        [.integer(self)]
    }

    public static func from(list: [ElementType]) -> Self? {
        list.first?.integer
    }
}
