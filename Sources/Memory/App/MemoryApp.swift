import AppKit
import SwiftData
import SwiftUI

@main
struct MemoryApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(for: [
            MemoryNote.self,
            MemoryCard.self,
            CardReviewLog.self
        ])
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        if let iconURL = Bundle.main.url(forResource: "AppIcon", withExtension: "png")
            ?? Bundle.module.url(forResource: "AppIcon", withExtension: "png"),
           let icon = NSImage(contentsOf: iconURL) {
            NSApp.applicationIconImage = icon
        }

        DispatchQueue.main.async {
            NSApp.activate(ignoringOtherApps: true)
            for window in NSApp.windows {
                if let visibleFrame = (window.screen ?? NSScreen.main)?.visibleFrame {
                    let launchSize = NSSize(
                        width: visibleFrame.width / 2,
                        height: visibleFrame.height / 3
                    )
                    let launchOrigin = NSPoint(
                        x: visibleFrame.midX - launchSize.width / 2,
                        y: visibleFrame.midY - launchSize.height / 2
                    )
                    window.setFrame(
                        NSRect(origin: launchOrigin, size: launchSize),
                        display: true
                    )
                }

                window.level = .floating
                window.collectionBehavior.insert(.canJoinAllSpaces)
                window.hidesOnDeactivate = false
                window.makeKeyAndOrderFront(nil)
            }
        }
    }
}
