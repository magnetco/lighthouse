import Foundation

actor LogTailer {
    private var tasks: [Int: Task<Void, Never>] = [:]
    private var logs: [Int: [String]] = [:]
    private let maxLines = 500
    
    func startTailing(pid: Int, onUpdate: @escaping ([String]) -> Void) {
        // Stop existing task if any
        stopTailing(pid: pid)
        
        // Create new task
        let task = Task {
            await tailLogs(pid: pid, onUpdate: onUpdate)
        }
        
        tasks[pid] = task
    }
    
    func stopTailing(pid: Int) {
        tasks[pid]?.cancel()
        tasks[pid] = nil
    }
    
    func stopAll() {
        for task in tasks.values {
            task.cancel()
        }
        tasks.removeAll()
        logs.removeAll()
    }
    
    func getLogs(for pid: Int) -> [String] {
        return logs[pid] ?? []
    }
    
    private func tailLogs(pid: Int, onUpdate: @escaping ([String]) -> Void) async {
        // Try to get the process's stderr and stdout
        // On macOS, we can use lsof to find open file descriptors
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/script")
        process.arguments = ["-q", "/dev/null", "/usr/bin/lsof", "-p", "\(pid)", "-a", "-d", "1,2"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                var logLines = logs[pid] ?? []
                logLines.append(contentsOf: output.components(separatedBy: .newlines).filter { !$0.isEmpty })
                
                // Keep only last maxLines
                if logLines.count > maxLines {
                    logLines = Array(logLines.suffix(maxLines))
                }
                
                logs[pid] = logLines
                
                await MainActor.run {
                    onUpdate(logLines)
                }
            }
        } catch {
            // Silently fail - process might not have accessible logs
        }
    }
}

// Simpler approach: Read process output via system log
class ProcessLogReader {
    static func getRecentLogs(for pid: Int, processName: String) async -> [String] {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/log")
        
        // Get logs from the last 5 minutes for this process
        let fiveMinutesAgo = Date().addingTimeInterval(-300)
        let dateFormatter = ISO8601DateFormatter()
        let startTime = dateFormatter.string(from: fiveMinutesAgo)
        
        process.arguments = [
            "show",
            "--predicate", "process == \"\(processName)\" OR processID == \(pid)",
            "--start", startTime,
            "--style", "compact",
            "--info",
            "--debug"
        ]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        do {
            try process.run()
            
            // Set a timeout
            let timeoutTask = Task {
                try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
                if process.isRunning {
                    process.terminate()
                }
            }
            
            process.waitUntilExit()
            timeoutTask.cancel()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                let lines = output.components(separatedBy: .newlines)
                    .filter { !$0.isEmpty && !$0.contains("Skipping info") }
                    .suffix(100) // Last 100 lines
                return Array(lines)
            }
        } catch {
            return ["Unable to read logs: \(error.localizedDescription)"]
        }
        
        return ["No logs available"]
    }
}
