import Foundation

private final class Box<ResultType>: @unchecked Sendable {
    var result: Result<ResultType, Error>? = nil
}

/// Unsafely awaits an async function from a synchronous context.
func _unsafeWait<ResultType>(_ task: @Sendable @escaping () async throws -> ResultType) throws -> ResultType {
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
