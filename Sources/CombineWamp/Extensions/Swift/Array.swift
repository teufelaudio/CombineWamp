extension Array: ElementTypeConvertible where Element == ElementType {
    public var asList: [ElementType] {
        return [.list(self)]
    }

    public static func from(list: [ElementType]) -> Self? {
        list.first?.list
    }
}
