import Foundation

private class Box<ResultType> {
    var result: Result<ResultType, Error>? = nil
}

/// Unsafely awaits an async function from a synchronous context.
func _unsafeWait<ResultType>(_ task: @escaping () async throws -> ResultType) throws -> ResultType {
    let box = Box<ResultType>()
    let semaphore = DispatchSemaphore(value: 0)
    Task {
        do {
            let value = try await task()
            box.result = .success(value)
        } catch {
            box.result = .failure(error)
        }
        semaphore.signal()
    }
    semaphore.wait()
    return try box.result!.get()
}
