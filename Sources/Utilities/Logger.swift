import Foundation
import os.log

@MainActor
class Logger {
    static let shared = Logger()
    private let log = OSLog(subsystem: "com.copycat.app", category: "Main")
    
    init() {}
    
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        os_log(.debug, log: log, "%@:%d %@ - %@", (file as NSString).lastPathComponent, line, function, message)
    }
    
    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        os_log(.info, log: log, "%@:%d %@ - %@", (file as NSString).lastPathComponent, line, function, message)
    }
    
    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        os_log(.error, log: log, "%@:%d %@ - %@", (file as NSString).lastPathComponent, line, function, message)
    }
    
    func fault(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        os_log(.fault, log: log, "%@:%d %@ - %@", (file as NSString).lastPathComponent, line, function, message)
    }
}
