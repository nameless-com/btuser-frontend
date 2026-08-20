import SwiftUI
import BTShared

struct CourtsView: View {
    @Environment(Session.self) private var session
    let arena: ArenaDTO
    @State private var courts: [CourtDTO] = []
    @State private var selected: CourtDTO?

    var body: some View {
        List(courts) { court in
            Button { selected = court } label: {
                HStack {
                    Text(court.name)
                    Spacer()
                    Text("\(court.pricePerHourCents.brl)/h").foregroundStyle(.secondary)
                }
            }
            .tint(.primary)
        }
        .navigationTitle(arena.name)
        .sheet(item: $selected) { NewBookingView(court: $0) }
        .task { courts = (try? await session.api.courts(arenaID: arena.id)) ?? [] }
    }
}
