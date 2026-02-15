#!/usr/bin/env swift

import Foundation

// Simple test to verify domain ping monitoring works
let testURL = "https://magnet.co"

print("Testing domain ping monitoring for: \(testURL)")
print(String(repeating: "=", count: 50))

// Create URL request
guard let url = URL(string: testURL) else {
    print("❌ Invalid URL")
    exit(1)
}

var request = URLRequest(url: url)
request.httpMethod = "HEAD"
request.timeoutInterval = 10
request.cachePolicy = .reloadIgnoringLocalCacheData
request.setValue("Lighthouse/1.0", forHTTPHeaderField: "User-Agent")

// Measure timing
let startTime = CFAbsoluteTimeGetCurrent()

let semaphore = DispatchSemaphore(value: 0)
var success = false

let task = URLSession.shared.dataTask(with: request) { data, response, error in
    let endTime = CFAbsoluteTimeGetCurrent()
    let responseTime = endTime - startTime
    
    if let error = error {
        print("❌ Error: \(error.localizedDescription)")
        print("   Response time: \(String(format: "%.0fms", responseTime * 1000))")
    } else if let httpResponse = response as? HTTPURLResponse {
        let statusEmoji = httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 ? "✅" : "⚠️"
        print("\(statusEmoji) Status Code: \(httpResponse.statusCode)")
        print("   Response time: \(String(format: "%.0fms", responseTime * 1000))")
        print("   Is reachable: true")
        success = true
    }
    
    semaphore.signal()
}

task.resume()
semaphore.wait()

print(String(repeating: "=", count: 50))
print(success ? "✅ Domain ping test PASSED" : "❌ Domain ping test FAILED")

exit(success ? 0 : 1)
