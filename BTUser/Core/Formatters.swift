import Foundation

extension Int {
    /// Centavos -> "R$ 80,00"
    var brl: String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.locale = Locale(identifier: "pt_BR")
        return f.string(from: NSNumber(value: Double(self) / 100)) ?? "R$ \(self / 100)"
    }
}

extension Date {
    var shortDateTime: String { formatted(date: .abbreviated, time: .shortened) }
}
