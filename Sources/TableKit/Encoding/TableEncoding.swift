import Foundation

struct TableEncoding: Encoder {
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey : Any] = [:]
    
    var data: Data
        
    init(codingPath: [CodingKey] = [], data: Data = Data()) {
        self.codingPath = codingPath
        self.data = data
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        KeyedEncodingContainer(TableKeyedEncodingContainer(codingPath: codingPath, data: data))
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        TableUnkeyedEncodingContainer(codingPath: codingPath, data: data)
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        TableSingleValueEncodingContainer(codingPath: codingPath, data: data)
    }
}

extension TableEncoding {
    final class Data {
        var rowKeys: [String] = []
        var columnKeys: [String] = []
        var dictionary: [String: [String: String]] = [:]
        
        func encode(key codingKey: [CodingKey], value: String?) {
            let rowKey = codingKey.first!.stringValue
            let columnKey = codingKey.dropFirst().map { $0.stringValue }.joined(separator: ".")
            
            if !rowKeys.contains(rowKey) {
                rowKeys.append(rowKey)
            }
            
            if !columnKeys.contains(columnKey) {
                columnKeys.append(columnKey)
            }
            
            dictionary[rowKey, default: [:]][columnKey] = value ?? "nil"
        }
    }
}
