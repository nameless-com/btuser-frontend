import SwiftUI
import BTShared

struct ArenasListView: View {
    @Environment(Session.self) private var session
    @State private var arenas: [ArenaDTO] = []
    @State private var error: String?

    var body: some View {
        NavigationStack {
            List(arenas) { arena in
                NavigationLink(value: arena) {
                    VStack(alignment: .leading) {
                        Text(arena.name).font(.headline)
                        Text("\(arena.address) · \(arena.city)").font(.subheadline).foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Arenas")
            .navigationDestination(for: ArenaDTO.self) { CourtsView(arena: $0) }
            .overlay { if let error { ContentUnavailableView(error, systemImage: "wifi.exclamationmark") } }
            .refreshable { await load() }
            .task { await load() }
        }
    }

    private func load() async {
        do { arenas = try await session.api.arenas(); error = nil }
        catch { self.error = error.localizedDescription }
    }
}
