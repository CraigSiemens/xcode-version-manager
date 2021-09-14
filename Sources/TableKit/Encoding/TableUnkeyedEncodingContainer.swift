import Foundation

struct TableUnkeyedEncodingContainer: UnkeyedEncodingContainer {
    var codingPath: [CodingKey]
    var count: Int = 0
    var data: TableEncoding.Data
    
    init(codingPath: [CodingKey], data: TableEncoding.Data) {
        self.codingPath = codingPath
        self.data = data
    }
    
    private struct IndexedCodingKey: CodingKey {
        let intValue: Int?
        let stringValue: String
                
        init(intValue: Int) {
            self.intValue = intValue
            self.stringValue = intValue.description
        }
        
        init?(stringValue: String) {
            return nil
        }
    }
    
    private mutating func nextIndexedKey() -> CodingKey {
        defer { count += 1 }
        return IndexedCodingKey(intValue: count)
    }
    
    mutating func encodeNil() throws {
        data.encode(key: codingPath + [nextIndexedKey()], value: nil)
    }
    
    mutating func encode(_ value: Bool) throws {
        data.encode(key: codingPath + [nextIndexedKey()], value: value.description)
    }
    
    mutating func encode(_ value: String) throws {
        data.encode(key: codingPath + [nextIndexedKey()], value: value)
    }
    
    mutating func encode(_ value: Double) throws {
        data.encode(key: codingPath + [nextIndexedKey()], value: value.description)
    }
    
    mutating func encode(_ value: Float) throws {
        data.encode(key: codingPath + [nextIndexedKey()], value: value.description)
    }
    
    mutating func encode(_ value: Int) throws {
        data.encode(key: codingPath + [nextIndexedKey()], value: value.description)
    }
    
    mutating func encode(_ value: Int8) throws {
        data.encode(key: codingPath + [nextIndexedKey()], value: value.description)
    }
    
    mutating func encode(_ value: Int16) throws {
        data.encode(key: codingPath + [nextIndexedKey()], value: value.description)
    }
    
    mutating func encode(_ value: Int32) throws {
        data.encode(key: codingPath + [nextIndexedKey()], value: value.description)
    }
    
    mutating func encode(_ value: Int64) throws {
        data.encode(key: codingPath + [nextIndexedKey()], value: value.description)
    }
    
    mutating func encode(_ value: UInt) throws {
        data.encode(key: codingPath + [nextIndexedKey()], value: value.description)
    }
    
    mutating func encode(_ value: UInt8) throws {
        data.encode(key: codingPath + [nextIndexedKey()], value: value.description)
    }
    
    mutating func encode(_ value: UInt16) throws {
        data.encode(key: codingPath + [nextIndexedKey()], value: value.description)
    }
    
    mutating func encode(_ value: UInt32) throws {
        data.encode(key: codingPath + [nextIndexedKey()], value: value.description)
    }
    
    mutating func encode(_ value: UInt64) throws {
        data.encode(key: codingPath + [nextIndexedKey()], value: value.description)
    }
    
    mutating func encode<T>(_ value: T) throws where T : Encodable {
        let tableEncoding = TableEncoding(codingPath: codingPath + [nextIndexedKey()], data: data)
        try value.encode(to: tableEncoding)
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = TableKeyedEncodingContainer<NestedKey>(codingPath: codingPath, data: data)
        return KeyedEncodingContainer(container)
    }
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        TableUnkeyedEncodingContainer(codingPath: codingPath, data: data)
    }
    
    mutating func superEncoder() -> Encoder {
        return TableEncoding(codingPath: codingPath, data: data)
    }
}
