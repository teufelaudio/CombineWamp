extension String: ElementTypeConvertible {
    public var asList: [ElementType] {
        [.string(self)]
    }

    public static func from(list: [ElementType]) -> Self? {
        list.first?.string
    }
}
