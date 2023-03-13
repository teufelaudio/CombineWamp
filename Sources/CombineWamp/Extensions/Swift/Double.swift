extension Double: ElementTypeConvertible {
    public var asList: [ElementType] {
        [.double(self)]
    }

    public static func from(list: [ElementType]) -> Self? {
        list.first?.double
    }
}
