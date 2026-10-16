import SwiftUI

@main
struct XTermApp: App {
    @AppStorage(Prefs.fontSize) private var fontSize = 13.0
    @AppStorage(Prefs.theme) private var theme = "Glass"

    init() {
        Prefs.register()
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
        .commands {
            CommandGroup(after: .newItem) {
                Button("New Tab") {
                    NSApp.sendAction(#selector(NSResponder.newWindowForTab(_:)), to: nil, from: nil)
                }
                .keyboardShortcut("t")
                Divider()
                Button("Split Right") { Pane.focused?.split(vertical: true) }
                    .keyboardShortcut("d")
                Button("Split Down") { Pane.focused?.split(vertical: false) }
                    .keyboardShortcut("d", modifiers: [.command, .shift])
            }
            CommandGroup(after: .toolbar) {
                Button("Bigger") { fontSize = min(fontSize + 1, 28) }
                    .keyboardShortcut("+") // matches ⌘= too
                Button("Smaller") { fontSize = max(fontSize - 1, 9) }
                    .keyboardShortcut("-")
                Button("Actual Size") { fontSize = 13 }
                    .keyboardShortcut("0")
                Picker("Theme", selection: $theme) {
                    ForEach(Theme.all, id: \.name) { Text($0.name).tag($0.name) }
                }
                Divider()
            }
        }

        Settings { SettingsView() }
    }
}
