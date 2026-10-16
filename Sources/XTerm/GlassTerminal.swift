import SwiftUI
import SwiftTerm

/// Liquid Glass window background with a transparent SwiftTerm terminal on top.
struct GlassTerminal: NSViewRepresentable {
    func makeNSView(context: Context) -> NSGlassEffectView {
        let glass = NSGlassEffectView()
        glass.style = .regular
        glass.tintColor = NSColor.windowBackgroundColor.withAlphaComponent(0.35) // contrast for text over busy wallpapers

        let term = LocalProcessTerminalView(frame: .zero)
        term.processDelegate = context.coordinator
        style(term)

        // Inset the text so it clears the floating traffic lights and rounded corners.
        let container = NSView()
        term.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(term)
        NSLayoutConstraint.activate([
            term.topAnchor.constraint(equalTo: container.topAnchor, constant: 32),
            term.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -10),
            term.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
            term.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
        ])
        glass.contentView = container

        let shell = ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/zsh"
        FileManager.default.changeCurrentDirectoryPath(NSHomeDirectory())
        // execName "-zsh" makes it a login shell, same as Terminal.app.
        term.startProcess(executable: shell, args: [], environment: nil,
                          execName: "-" + (shell as NSString).lastPathComponent)

        DispatchQueue.main.async { term.window?.makeFirstResponder(term) }
        return glass
    }

    func updateNSView(_ nsView: NSGlassEffectView, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator() }

    private func style(_ term: LocalProcessTerminalView) {
        term.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        term.nativeBackgroundColor = .clear
        term.nativeForegroundColor = .labelColor
        term.caretColor = .controlAccentColor
        term.selectedTextBackgroundColor = .controlAccentColor.withAlphaComponent(0.35)
        term.installColors(palette)
    }

    final class Coordinator: NSObject, LocalProcessTerminalViewDelegate {
        func sizeChanged(source: LocalProcessTerminalView, newCols: Int, newRows: Int) {}
        func setTerminalTitle(source: LocalProcessTerminalView, title: String) {
            source.window?.title = title // shows in native window tabs
        }
        func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {}
        func processTerminated(source: TerminalView, exitCode: Int32?) {
            DispatchQueue.main.async { source.window?.close() }
        }
    }
}

/// Soft ANSI palette (Apple system colors) that stays readable on glass.
private let palette: [SwiftTerm.Color] = [
    0x1C1C1E, 0xFF453A, 0x32D74B, 0xFFD60A, 0x0A84FF, 0xBF5AF2, 0x64D2FF, 0xD1D1D6,
    0x636366, 0xFF6961, 0x5DE27A, 0xFFE45C, 0x409CFF, 0xDA8FFF, 0x8ADFFF, 0xFFFFFF,
].map { hex in
    func c(_ shift: Int) -> UInt16 { UInt16((hex >> shift) & 0xFF) * 257 }
    return SwiftTerm.Color(red: c(16), green: c(8), blue: c(0))
}
