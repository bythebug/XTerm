import SwiftUI

/// Liquid Glass window background holding one or more transparent terminal panes.
struct GlassTerminal: NSViewRepresentable {
    // Reading these makes SwiftUI call updateNSView when Settings change.
    @AppStorage(Prefs.theme) private var theme = "Glass"
    @AppStorage(Prefs.fontFamily) private var fontFamily = ""
    @AppStorage(Prefs.fontSize) private var fontSize = 13.0
    @AppStorage(Prefs.glass) private var glass = 0.35

    func makeNSView(context: Context) -> NSGlassEffectView {
        let glassView = NSGlassEffectView()
        glassView.style = .regular

        // Inset the panes so text clears the floating traffic lights and rounded corners.
        let container = NSView()
        let root = NSView()
        root.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(root)
        NSLayoutConstraint.activate([
            root.topAnchor.constraint(equalTo: container.topAnchor, constant: 32),
            root.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -10),
            root.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
            root.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
        ])
        glassView.contentView = container

        // Open in the folder of the terminal you were just using (new window or tab).
        let pane = Pane(cwd: Pane.focused?.cwd)
        root.addSubview(pane)
        pane.frame = root.bounds
        DispatchQueue.main.async { pane.window?.makeFirstResponder(pane) }
        return glassView
    }

    func updateNSView(_ glassView: NSGlassEffectView, context: Context) {
        let t = Theme.named(theme)
        glassView.appearance = t.appearance.map { NSAppearance(named: $0)! }
        glassView.tintColor = NSColor.windowBackgroundColor.withAlphaComponent(max(glass, t.minTint))
        Pane.all(in: glassView).forEach { $0.applySettings() }
    }
}
