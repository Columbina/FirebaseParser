public struct KeyValue<T: Codable>: Codable {
    public let key: String
    public let value: T
}

public struct DynamicChildrenArray<T: Codable>: Codable {

    private var array: [KeyValue<T>]
    
    private struct DynamicCodingKeys: CodingKey {

        // Use for string-keyed dictionary
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        // Use for integer-keyed dictionary
        var intValue: Int?
        init?(intValue: Int) {
            // We are not using this, thus just return nil
            return nil
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)

        var tempArray = [KeyValue<T>]()

        for key in container.allKeys {
            let decodedValue = try container
                .decode(T.self, forKey: DynamicCodingKeys(stringValue: key.stringValue)!)
            
            let nodeItem = KeyValue(key: key.stringValue,value: decodedValue)
            tempArray.append(nodeItem)
        }

        array = tempArray
    }
}

extension DynamicChildrenArray: Collection {
    public typealias ArrayType = [KeyValue<T>]
    // Required nested types, that tell Swift what our collection contains
    public typealias Index = ArrayType.Index
    public typealias Element = ArrayType.Element

    // The upper and lower bounds of the collection, used in iterations
    public var startIndex: Index { return array.startIndex }
    public var endIndex: Index { return array.endIndex }

    // Required subscript, based on a dictionary index
    public subscript(index: Index) -> Iterator.Element {
        array[index]
    }
    
    public subscript(key: String) -> T? {
        array.first { $0.key == key }?.value
    }

    // Method that returns the next index when iterating
    public func index(after i: Index) -> Index {
        return array.index(after: i)
    }
}

public struct FirebaseDynamicRoot<T: Codable>: Codable {
    private var array: DynamicChildrenArray<T>
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        array = try container.decode(DynamicChildrenArray<T>.self)
    }
}

extension FirebaseDynamicRoot: Collection {
    public typealias ArrayType = DynamicChildrenArray<T>
    // Required nested types, that tell Swift what our collection contains
    public typealias Index = ArrayType.Index
    public typealias Element = ArrayType.Element

    // The upper and lower bounds of the collection, used in iterations
    public var startIndex: Index { return array.startIndex }
    public var endIndex: Index { return array.endIndex }

    // Required subscript, based on a dictionary index
    public subscript(index: Index) -> Element {
        array[index]
    }
    
    public subscript(key: String) -> T? {
        array.first { $0.key == key }?.value
    }

    // Method that returns the next index when iterating
    public func index(after i: Index) -> Index {
        return array.index(after: i)
    }
}
