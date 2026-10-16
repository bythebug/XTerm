import AppKit
import SwiftTerm

/// One shell. Panes split by replacing themselves with an NSSplitView holding two panes.
final class Pane: LocalProcessTerminalView {
    /// The pane the user is typing in, if any.
    static var focused: Pane? {
        (NSApp.keyWindow?.firstResponder ?? NSApp.mainWindow?.firstResponder) as? Pane
    }

    private var applied = ""
    private let events = Events() // processDelegate is weak, so the pane owns it

    init(cwd: String?) {
        super.init(frame: NSRect(x: 0, y: 0, width: 400, height: 300))
        autoresizingMask = [.width, .height]
        processDelegate = events
        bellStyle = .visual // glass flashes instead of beeping
        caretColor = .controlAccentColor
        selectedTextBackgroundColor = .controlAccentColor.withAlphaComponent(0.35)
        applySettings()

        // Right-click menu, like Terminal.app. Targets self so it acts on the pane you clicked.
        let menu = NSMenu()
        for (title, action, key) in [
            ("Copy", #selector(copy(_:)), "c"), ("Paste", #selector(paste(_:)), "v"),
            ("Select All", #selector(selectAll(_:)), "a"), ("", nil, ""),
            ("Split Right", #selector(splitRight), "d"), ("Split Down", #selector(splitDown), "D"),
        ] as [(String, Selector?, String)] {
            guard let action else { menu.addItem(.separator()); continue }
            menu.addItem(withTitle: title, action: action, keyEquivalent: key).target = self
        }
        self.menu = menu

        let shell = ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/zsh"
        // execName "-zsh" makes it a login shell, same as Terminal.app.
        startProcess(executable: shell, execName: "-" + (shell as NSString).lastPathComponent,
                     currentDirectory: cwd ?? NSHomeDirectory())
    }

    required init?(coder: NSCoder) { fatalError("not used") }

    /// Applies font and theme from Settings. Cheap to call often: skips if nothing changed.
    func applySettings() {
        let d = UserDefaults.standard
        let size = d.double(forKey: Prefs.fontSize)
        let family = d.string(forKey: Prefs.fontFamily) ?? ""
        let theme = Theme.named(d.string(forKey: Prefs.theme))
        let key = "\(family)|\(size)|\(theme.name)"
        guard key != applied else { return }
        applied = key

        font = NSFont(name: family, size: size) ?? .monospacedSystemFont(ofSize: size, weight: .regular)
        nativeBackgroundColor = .clear
        nativeForegroundColor = theme.foreground
        installColors(theme.palette)
    }

    /// The shell's working directory, so new panes, tabs and windows open where you are.
    var cwd: String? {
        var info = proc_vnodepathinfo()
        let pid = process.shellPid
        guard pid > 0, proc_pidinfo(pid, PROC_PIDVNODEPATHINFO, 0, &info, Int32(MemoryLayout.size(ofValue: info))) > 0
        else { return nil }
        return withUnsafeBytes(of: info.pvi_cdir.vip_path) { String(cString: $0.bindMemory(to: CChar.self).baseAddress!) }
    }

    func split(vertical: Bool) {
        guard let parent = superview else { return }
        let split = NSSplitView(frame: frame)
        split.isVertical = vertical
        split.dividerStyle = .thin
        split.autoresizingMask = [.width, .height]
        let pane = Pane(cwd: cwd)
        parent.replaceSubview(self, with: split)
        split.addSubview(self)
        split.addSubview(pane)
        split.adjustSubviews()
        split.setPosition((vertical ? split.bounds.width : split.bounds.height) / 2, ofDividerAt: 0)
        window?.makeFirstResponder(pane)
    }

    @objc private func splitRight() { split(vertical: true) }
    @objc private func splitDown() { split(vertical: false) }

    // SwiftTerm disables menu actions it doesn't know about.
    override func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
        if item.action == #selector(splitRight) || item.action == #selector(splitDown) { return true }
        return super.validateUserInterfaceItem(item)
    }

    /// Removes this pane; the last pane in a window closes the window.
    func close() {
        let win = window
        guard let split = superview as? NSSplitView else { win?.close(); return }
        removeFromSuperview()
        if split.subviews.count == 1, let only = split.subviews.first {
            only.removeFromSuperview()
            only.frame = split.frame
            split.superview?.replaceSubview(split, with: only)
        }
        if let content = win?.contentView, let next = Pane.all(in: content).first {
            win?.makeFirstResponder(next)
        }
    }

    static func all(in view: NSView) -> [Pane] {
        (view as? Pane).map { [$0] } ?? view.subviews.flatMap { all(in: $0) }
    }
}

private final class Events: LocalProcessTerminalViewDelegate {
    func sizeChanged(source: LocalProcessTerminalView, newCols: Int, newRows: Int) {}
    func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {}
    func setTerminalTitle(source: LocalProcessTerminalView, title: String) {
        source.window?.title = title // shows in native window tabs
    }
    func processTerminated(source: TerminalView, exitCode: Int32?) {
        DispatchQueue.main.async { (source as? Pane)?.close() }
    }
}
