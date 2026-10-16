import SwiftUI
import SwiftTerm

enum Prefs {
    static let fontFamily = "fontFamily" // "" = SF Mono
    static let fontSize = "fontSize"
    static let glass = "glass"           // background tint, 0 = clear glass
    static let theme = "theme"

    static func register() {
        UserDefaults.standard.register(defaults: [fontFamily: "", fontSize: 13.0, glass: 0.35, theme: "Glass"])
    }
}

struct Theme {
    let name: String
    let appearance: NSAppearance.Name? // nil = follow system light/dark
    let foreground: NSColor
    let minTint: Double
    let palette: [SwiftTerm.Color]

    init(_ name: String, _ appearance: NSAppearance.Name?, _ foreground: NSColor, minTint: Double = 0, _ hex: [Int]) {
        self.name = name
        self.appearance = appearance
        self.foreground = foreground
        self.minTint = minTint
        palette = hex.map { hex in
            func c(_ shift: Int) -> UInt16 { UInt16((hex >> shift) & 0xFF) * 257 }
            return SwiftTerm.Color(red: c(16), green: c(8), blue: c(0))
        }
    }

    static let all = [
        Theme("Glass", nil, .labelColor, [
            0x1C1C1E, 0xFF453A, 0x32D74B, 0xFFD60A, 0x0A84FF, 0xBF5AF2, 0x64D2FF, 0xD1D1D6,
            0x636366, 0xFF6961, 0x5DE27A, 0xFFE45C, 0x409CFF, 0xDA8FFF, 0x8ADFFF, 0xFFFFFF]),
        Theme("Midnight", .darkAqua, NSColor(white: 0.9, alpha: 1), [
            0x15161E, 0xF7768E, 0x9ECE6A, 0xE0AF68, 0x7AA2F7, 0xBB9AF7, 0x7DCFFF, 0xA9B1D6,
            0x414868, 0xFF8FA3, 0xB9F27C, 0xFFC777, 0x8DB6FF, 0xC9A9FF, 0x9BDBFF, 0xC0CAF5]),
        Theme("Paper", .aqua, NSColor(white: 0.12, alpha: 1), [
            0x1D1D1F, 0xC41A16, 0x007400, 0x826B28, 0x0B4F79, 0xAA0D91, 0x3E8087, 0x6E6E73,
            0x48484A, 0xE0362A, 0x1E8E3E, 0x9A6B00, 0x0A60FE, 0xA52A9C, 0x1A8E99, 0x3A3A3C]),
        Theme("High Contrast", .darkAqua, .white, minTint: 0.75, [
            0x000000, 0xFF5555, 0x55FF55, 0xFFFF55, 0x5C9DFF, 0xFF55FF, 0x55FFFF, 0xFFFFFF,
            0x808080, 0xFF8080, 0x80FF80, 0xFFFF80, 0x80B4FF, 0xFF80FF, 0x80FFFF, 0xFFFFFF]),
    ]

    static func named(_ name: String?) -> Theme { all.first { $0.name == name } ?? all[0] }
}

struct SettingsView: View {
    @AppStorage(Prefs.theme) private var theme = "Glass"
    @AppStorage(Prefs.fontFamily) private var fontFamily = ""
    @AppStorage(Prefs.fontSize) private var fontSize = 13.0
    @AppStorage(Prefs.glass) private var glass = 0.35

    private let families = NSFontManager.shared.availableFontFamilies.filter {
        NSFont(name: $0, size: 12)?.isFixedPitch == true
    }

    var body: some View {
        Form {
            Picker("Theme", selection: $theme) {
                ForEach(Theme.all, id: \.name) { Text($0.name).tag($0.name) }
            }
            Picker("Font", selection: $fontFamily) {
                Text("SF Mono").tag("")
                ForEach(families, id: \.self) { Text($0).tag($0) }
            }
            Slider(value: $fontSize, in: 9...28, step: 1) {
                Text("Size: \(Int(fontSize)) pt")
            }
            Slider(value: $glass, in: 0...0.9) {
                Text("Background")
            } minimumValueLabel: { Text("Clear") } maximumValueLabel: { Text("Solid") }
        }
        .formStyle(.grouped)
        .frame(width: 440)
    }
}
