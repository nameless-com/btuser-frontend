import SwiftUI
import BTShared

struct NewBookingView: View {
    @Environment(Session.self) private var session
    @Environment(\.dismiss) private var dismiss
    let court: CourtDTO

    @State private var start = Calendar.current.date(bySetting: .minute, value: 0, of: Date().addingTimeInterval(3600)) ?? Date()
    @State private var hours = 1.0
    @State private var error: String?
    @State private var saving = false

    private var end: Date { start.addingTimeInterval(hours * 3600) }
    private var total: Int { Int(Double(court.pricePerHourCents) * hours) }

    var body: some View {
        NavigationStack {
            Form {
                Section(court.name) {
                    DatePicker("Início", selection: $start, in: Date()...)
                    Stepper("Duração: \(hours, specifier: "%.1f") h", value: $hours, in: 0.5...4, step: 0.5)
                    LabeledContent("Total", value: total.brl)
                }
                if let error { Section { Text(error).foregroundStyle(.red) } }
            }
            .navigationTitle("Reservar")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirmar") { Task { await confirm() } }.disabled(saving)
                }
            }
        }
    }

    private func confirm() async {
        saving = true; defer { saving = false }
        do {
            _ = try await session.api.createBooking(CreateBookingRequest(courtID: court.id, startsAt: start, endsAt: end))
            dismiss()
        } catch { self.error = error.localizedDescription }
    }
}
