import Foundation

enum ProcessManagerError: Error, LocalizedError {
    case killFailed(Int, String)
    case processNotFound(Int)

    var errorDescription: String? {
        switch self {
        case .killFailed(let pid, let message):
            return "Failed to kill process \(pid): \(message)"
        case .processNotFound(let pid):
            return "Process \(pid) not found"
        }
    }
}

class ProcessManager {

    /// Kill a process gracefully (SIGTERM)
    func killProcess(pid: Int) async throws {
        let command = "kill \(pid) 2>&1"
        do {
            try await ShellExecutor.executeIgnoringOutput(command)
        } catch let error as ShellError {
            throw ProcessManagerError.killFailed(pid, error.localizedDescription)
        }
    }

    /// Force kill a process (SIGKILL)
    func forceKill(pid: Int) async throws {
        let command = "kill -9 \(pid) 2>&1"
        do {
            try await ShellExecutor.executeIgnoringOutput(command)
        } catch let error as ShellError {
            throw ProcessManagerError.killFailed(pid, error.localizedDescription)
        }
    }

    /// Check if a process is still running
    func isRunning(pid: Int) async -> Bool {
        do {
            let output = try await ShellExecutor.execute("ps -p \(pid) -o pid= 2>/dev/null")
            return !output.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        } catch {
            return false
        }
    }

    /// Kill process and verify it's terminated
    func killAndVerify(pid: Int, forceAfterDelay: Bool = true) async throws -> Bool {
        // First, try graceful kill
        try await killProcess(pid: pid)

        // Wait a moment for process to terminate
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        // Check if still running
        if await isRunning(pid: pid) {
            if forceAfterDelay {
                // Force kill if still running
                try await forceKill(pid: pid)
                try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
                return !(await isRunning(pid: pid))
            }
            return false
        }

        return true
    }

    /// Get detailed process info
    func getProcessInfo(pid: Int) async -> String? {
        do {
            let output = try await ShellExecutor.execute("ps -p \(pid) -o command= 2>/dev/null")
            let command = output.trimmingCharacters(in: .whitespacesAndNewlines)
            return command.isEmpty ? nil : command
        } catch {
            return nil
        }
    }
}
