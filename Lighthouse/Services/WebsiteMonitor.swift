import Foundation

class WebsiteMonitor {
    private let session: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 10
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.session = URLSession(configuration: config)
    }
    
    /// Ping a single URL and return detailed result
    func ping(url: String) async -> PingResult {
        // Validate and create URL
        guard let validURL = URL(string: url) else {
            return PingResult(
                timestamp: Date(),
                statusCode: nil,
                responseTime: 0,
                latency: 0,
                isReachable: false,
                errorMessage: "Invalid URL"
            )
        }
        
        // Create request
        var request = URLRequest(url: validURL)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 10
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        // Add user agent to avoid bot blocking
        request.setValue("Lighthouse/1.0", forHTTPHeaderField: "User-Agent")
        
        // Measure timing
        let startTime = CFAbsoluteTimeGetCurrent()
        
        do {
            let (_, response) = try await session.data(for: request)
            let endTime = CFAbsoluteTimeGetCurrent()
            let responseTime = endTime - startTime
            
            if let httpResponse = response as? HTTPURLResponse {
                return PingResult(
                    timestamp: Date(),
                    statusCode: httpResponse.statusCode,
                    responseTime: responseTime,
                    latency: responseTime,
                    isReachable: true,
                    errorMessage: nil
                )
            } else {
                return PingResult(
                    timestamp: Date(),
                    statusCode: nil,
                    responseTime: responseTime,
                    latency: responseTime,
                    isReachable: true,
                    errorMessage: nil
                )
            }
        } catch let error as URLError {
            let endTime = CFAbsoluteTimeGetCurrent()
            let responseTime = endTime - startTime
            
            let errorMessage: String
            switch error.code {
            case .timedOut:
                errorMessage = "Timeout"
            case .cannotFindHost:
                errorMessage = "Host not found"
            case .cannotConnectToHost:
                errorMessage = "Cannot connect"
            case .networkConnectionLost:
                errorMessage = "Connection lost"
            case .notConnectedToInternet:
                errorMessage = "No internet"
            case .secureConnectionFailed:
                errorMessage = "SSL error"
            default:
                errorMessage = "Network error"
            }
            
            return PingResult(
                timestamp: Date(),
                statusCode: nil,
                responseTime: responseTime,
                latency: responseTime,
                isReachable: false,
                errorMessage: errorMessage
            )
        } catch {
            let endTime = CFAbsoluteTimeGetCurrent()
            let responseTime = endTime - startTime
            
            return PingResult(
                timestamp: Date(),
                statusCode: nil,
                responseTime: responseTime,
                latency: responseTime,
                isReachable: false,
                errorMessage: error.localizedDescription
            )
        }
    }
    
    /// Monitor multiple websites concurrently
    func monitorWebsites(_ websites: [WebsiteInfo]) async -> [UUID: PingResult] {
        await withTaskGroup(of: (UUID, PingResult).self) { group in
            for website in websites where website.isEnabled {
                group.addTask {
                    let result = await self.ping(url: website.url)
                    return (website.id, result)
                }
            }
            
            var results: [UUID: PingResult] = [:]
            for await (id, result) in group {
                results[id] = result
            }
            return results
        }
    }
    
    /// Validate URL format
    static func isValidURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else {
            return false
        }
        
        // Must have a scheme (http or https)
        guard let scheme = url.scheme?.lowercased() else {
            return false
        }
        
        guard scheme == "http" || scheme == "https" else {
            return false
        }
        
        // Must have a host
        guard url.host != nil else {
            return false
        }
        
        return true
    }
    
    /// Normalize URL (add https:// if missing)
    static func normalizeURL(_ urlString: String) -> String {
        var normalized = urlString.trimmingCharacters(in: .whitespaces)
        
        // Add https:// if no scheme
        if !normalized.hasPrefix("http://") && !normalized.hasPrefix("https://") {
            normalized = "https://" + normalized
        }
        
        return normalized
    }
}
