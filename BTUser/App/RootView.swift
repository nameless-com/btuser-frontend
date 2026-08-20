import SwiftUI

struct RootView: View {
    @Environment(Session.self) private var session

    var body: some View {
        if session.isRestoring {
            ProgressView("Carregando…")
        } else if session.isLoggedIn {
            TabView {
                ArenasListView()
                    .tabItem { Label("Arenas", systemImage: "sun.max") }
                MyBookingsView()
                    .tabItem { Label("Reservas", systemImage: "calendar") }
                ProfileView()
                    .tabItem { Label("Perfil", systemImage: "person") }
            }
        } else {
            LoginView()
        }
    }
}

struct ProfileView: View {
    @Environment(Session.self) private var session
    var body: some View {
        NavigationStack {
            List {
                if let u = session.user {
                    LabeledContent("Nome", value: u.name)
                    LabeledContent("E-mail", value: u.email)
                }
                Button("Sair", role: .destructive) { Task { await session.logout() } }
            }
            .navigationTitle("Perfil")
        }
    }
}
