import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var connectionManager: ConnectionManager!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        Task { @MainActor in
            connectionManager = ConnectionManager()
            setupWindow()
        }
    }
    
    @MainActor
    private func setupWindow() {
        let contentView = ConnectionManagerView()
            .environmentObject(connectionManager)
        
        window = NSWindow(
            contentRect: NSRect(x: 200, y: 200, width: 1200, height: 800),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "CopyCat - 数据库管理"
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        window.isReleasedWhenClosed = false
        
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

@main
struct CopyCatApp {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.run()
    }
}
