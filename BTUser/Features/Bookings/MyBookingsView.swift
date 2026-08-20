import SwiftUI
import BTShared

struct MyBookingsView: View {
    @Environment(Session.self) private var session
    @State private var bookings: [BookingDTO] = []

    var body: some View {
        NavigationStack {
            List {
                ForEach(bookings) { b in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(b.startsAt.shortDateTime).font(.headline)
                            Spacer()
                            Text(b.status.label)
                                .font(.caption).padding(.horizontal, 8).padding(.vertical, 2)
                                .background(b.status.color.opacity(0.15), in: Capsule())
                        }
                        Text("até \(b.endsAt.formatted(date: .omitted, time: .shortened)) · \(b.totalCents.brl)")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                    .swipeActions {
                        if b.status != .cancelled {
                            Button("Cancelar", role: .destructive) { Task { await cancel(b) } }
                        }
                    }
                }
            }
            .overlay { if bookings.isEmpty { ContentUnavailableView("Nenhuma reserva", systemImage: "calendar.badge.plus") } }
            .navigationTitle("Minhas reservas")
            .refreshable { await load() }
            .task { await load() }
        }
    }

    private func load() async { bookings = (try? await session.api.bookings()) ?? [] }
    private func cancel(_ b: BookingDTO) async {
        try? await session.api.cancelBooking(b.id)
        await load()
    }
}

extension BookingStatus {
    var label: String {
        switch self { case .pending: "Pendente"; case .confirmed: "Confirmada"; case .cancelled: "Cancelada" }
    }
    var color: Color {
        switch self { case .pending: .orange; case .confirmed: .green; case .cancelled: .red }
    }
}
