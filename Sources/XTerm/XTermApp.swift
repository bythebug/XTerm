import SwiftUI

@main
struct XTermApp: App {
    init() {
        // Needed so `swift run` gets a Dock icon, menu bar and keyboard focus.
        NSApplication.shared.setActivationPolicy(.regular)
        NSApplication.shared.activate()
    }

    var body: some Scene {
        WindowGroup {
            GlassTerminal()
                .ignoresSafeArea()
                .frame(minWidth: 480, minHeight: 280)
                .containerBackground(.clear, for: .window)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 760, height: 480)
    }
}
