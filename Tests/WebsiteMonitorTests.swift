import XCTest
@testable import Lighthouse

final class WebsiteMonitorTests: XCTestCase {
    var monitor: WebsiteMonitor!
    
    override func setUp() {
        super.setUp()
        monitor = WebsiteMonitor()
    }
    
    func testPingMagnetCo() async throws {
        // Test pinging magnet.co
        let result = await monitor.ping(url: "https://magnet.co")
        
        // Verify the result
        XCTAssertTrue(result.isReachable, "magnet.co should be reachable")
        XCTAssertNotNil(result.statusCode, "Should have a status code")
        XCTAssertEqual(result.statusCode, 200, "Should return 200 OK")
        XCTAssertGreaterThan(result.responseTime, 0, "Should have a response time")
        XCTAssertNil(result.errorMessage, "Should not have an error message")
        
        print("✅ Ping test for magnet.co PASSED")
        print("   Status: \(result.statusCode ?? 0)")
        print("   Response time: \(String(format: "%.0fms", result.responseTime * 1000))")
        print("   Reachable: \(result.isReachable)")
    }
    
    func testPingInvalidDomain() async throws {
        // Test pinging an invalid domain
        let result = await monitor.ping(url: "https://this-domain-definitely-does-not-exist-12345.com")
        
        // Verify the result
        XCTAssertFalse(result.isReachable, "Invalid domain should not be reachable")
        XCTAssertNotNil(result.errorMessage, "Should have an error message")
        
        print("✅ Invalid domain test PASSED")
        print("   Error: \(result.errorMessage ?? "Unknown")")
    }
    
    func testMonitorMultipleWebsites() async throws {
        // Create test websites
        let websites = [
            WebsiteInfo(url: "https://magnet.co", displayName: "Magnet"),
            WebsiteInfo(url: "https://google.com", displayName: "Google"),
            WebsiteInfo(url: "https://apple.com", displayName: "Apple")
        ]
        
        // Monitor all websites
        let results = await monitor.monitorWebsites(websites)
        
        // Verify results
        XCTAssertEqual(results.count, 3, "Should have results for all websites")
        
        for website in websites {
            guard let result = results[website.id] else {
                XCTFail("Missing result for \(website.displayName)")
                continue
            }
            
            XCTAssertTrue(result.isReachable, "\(website.displayName) should be reachable")
            print("✅ \(website.displayName): \(result.statusCode ?? 0) - \(String(format: "%.0fms", result.responseTime * 1000))")
        }
    }
}
