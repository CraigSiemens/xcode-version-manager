import Foundation

extension Array {
    func concurrentMap<T>(_ transform: @escaping (Element) throws -> T) throws -> [T] {
        var results = Array<Result<T, Error>?>(repeating: nil, count: count)
        
        let q = DispatchQueue(label: "sync queue")
        
        DispatchQueue.concurrentPerform(iterations: count) { idx in
            let element = self[idx]
            let result = Result { try transform(element) }
            q.sync {
                results[idx] = result
            }
        }
        
        return try results.compactMap { try $0?.get() }
    }
}
