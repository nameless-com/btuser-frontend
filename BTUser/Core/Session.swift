import Foundation
import Observation
import BTShared

/// Estado global de autenticação. Único ponto que cria o APIClient.
@MainActor
@Observable
final class Session {
    let api: APIClient
    private(set) var user: UserDTO?
    private(set) var isRestoring = true

    /// Papel que este app aceita. Evita logar com conta de outro app.
    static let requiredRole: UserRole = .player

    init(api: APIClient? = nil) {
        self.api = api ?? APIClient(baseURL: AppConfig.apiBaseURL, tokenStore: KeychainTokenStore())
    }

    var isLoggedIn: Bool { user != nil }

    func restore() async {
        defer { isRestoring = false }
        if let me = try? await api.me(), me.role == Self.requiredRole { user = me }
    }

    func login(email: String, password: String) async throws {
        let res = try await api.login(LoginRequest(email: email, password: password))
        try accept(res.user)
    }

    func register(name: String, email: String, password: String) async throws {
        let res = try await api.register(RegisterRequest(name: name, email: email, password: password, role: Self.requiredRole))
        try accept(res.user)
    }

    func logout() async {
        await api.logout()
        user = nil
    }

    private func accept(_ u: UserDTO) throws {
        guard u.role == Self.requiredRole else {
            Task { await api.logout() }
            throw APIError.server(status: 403, reason: "Esta conta não é de \(Self.requiredRole.rawValue). Use o outro app.")
        }
        user = u
    }
}
