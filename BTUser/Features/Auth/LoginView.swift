import SwiftUI
import BTShared

struct LoginView: View {
    @Environment(Session.self) private var session
    @State private var email = ""
    @State private var password = ""
    @State private var error: String?
    @State private var loading = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("E-mail", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    SecureField("Senha", text: $password)
                        .textContentType(.password)
                }
                if let error { Section { Text(error).foregroundStyle(.red) } }
                Section {
                    Button {
                        Task { await submit() }
                    } label: {
                        if loading { ProgressView() } else { Text("Entrar") }
                    }
                    .disabled(loading || email.isEmpty || password.isEmpty)
                }
            }
            .navigationTitle("BT200")
        }
    }

    private func submit() async {
        loading = true; defer { loading = false }
        error = nil
        do { try await session.login(email: email, password: password) }
        catch { self.error = error.localizedDescription }
    }
}
