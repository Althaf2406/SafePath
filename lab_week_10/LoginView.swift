// MARK: - LoginView.swift

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var showRegister: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                VStack(spacing: 32) {
                    Spacer()

                    // MARK: - Header
                    VStack(spacing: 8) {
                        Image(systemName: "book.closed.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 72, height: 72)
                            .foregroundStyle(.primary)

                        Text("Login")
                            .font(.title.bold())

                        Text("Catatan setiap perjalanan hidup.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    // MARK: - Form
                    VStack(spacing: 16) {
                        TextField("Email", text: $authVM.email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)

                        SecureField("Password", text: $authVM.password)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)

                        // Error message
                        if let error = authVM.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                        }

                        // Login Button
                        Button {
                            Task { await authVM.login() }
                        } label: {
                            ZStack {
                                if authVM.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Login")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primary)
                            .foregroundStyle(Color(.systemBackground))
                            .cornerRadius(10)
                        }
                        .disabled(authVM.isLoading)
                    }
                    .padding(.horizontal)

                    // Register Link
                    Button("Register New Account") {
                        showRegister = true
                    }
                    .font(.subheadline)

                    Spacer()
                }
                .padding()
            }
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
                    .environmentObject(authVM)
            }
        }
    }
}
