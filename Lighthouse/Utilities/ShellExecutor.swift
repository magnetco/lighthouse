import Foundation

enum ShellError: Error, LocalizedError {
    case executionFailed(Int32, String)
    case invalidOutput

    var errorDescription: String? {
        switch self {
        case .executionFailed(let code, let message):
            return "Shell command failed with code \(code): \(message)"
        case .invalidOutput:
            return "Could not decode shell output"
        }
    }
}

struct ShellExecutor {

    /// Execute a shell command and return the output
    @discardableResult
    static func execute(_ command: String) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let process = Process()
                let outputPipe = Pipe()
                let errorPipe = Pipe()

                process.executableURL = URL(fileURLWithPath: "/bin/zsh")
                process.arguments = ["-c", command]
                process.standardOutput = outputPipe
                process.standardError = errorPipe

                do {
                    try process.run()
                    process.waitUntilExit()

                    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

                    let output = String(data: outputData, encoding: .utf8) ?? ""
                    let errorOutput = String(data: errorData, encoding: .utf8) ?? ""

                    if process.terminationStatus != 0 && output.isEmpty {
                        continuation.resume(throwing: ShellError.executionFailed(process.terminationStatus, errorOutput))
                    } else {
                        continuation.resume(returning: output)
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Execute a command that doesn't need output (like kill)
    static func executeIgnoringOutput(_ command: String) async throws {
        _ = try await execute(command)
    }
}
