//
//  ProfilePageView.swift
//  SafePath
//
//  Created by student on 29/05/26.
//

import SwiftUI
import Combine

/// Person 2: Profile page matching the screenshot design.
struct ProfilePageView: View {
    @Environment(\.dismiss) var dismiss

    @State private var showLogoutConfirm = false
    @State private var showLogoutToast   = false

    // Placeholder user data — replace with ViewModel binding
    private let userName     = "Muhammad Althaf"
    private let userEmail    = "althaf.m@example.com"
    private let userLocation = "Surabaya, East Java"

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                // MARK: Avatar + Identity
                avatarSection
                    .padding(.top, 24)
                    .padding(.bottom, 20)

                // MARK: Edit Profile & Settings
                accountMenuCard
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)

                // MARK: Safety Connections
                safetyConnectionsSection
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)

                // MARK: Device Status
                deviceStatusSection
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)

                // MARK: Logout Button
                logoutButton
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
            }
        }
        .background(SafePathColors.backgroundLight.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(SafePathColors.primaryBlue)
                        .font(.system(size: 18, weight: .bold))
                    Text("SafePath")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(SafePathColors.primaryBlue)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(SafePathColors.textSecondary.opacity(0.5))
            }
        }
        .confirmationDialog("Are you sure you want to log out?", isPresented: $showLogoutConfirm, titleVisibility: .visible) {
            Button("Logout", role: .destructive) {
                withAnimation { showLogoutToast = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation { showLogoutToast = false }
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .overlay(
            Group {
                if showLogoutToast { toastOverlay }
            }
        )
    }

    // MARK: - Avatar Section

    private var avatarSection: some View {
        VStack(spacing: 10) {
            ZStack(alignment: .bottomTrailing) {
                // Avatar placeholder
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 90))
                    .foregroundColor(SafePathColors.textSecondary.opacity(0.25))
                    .frame(width: 100, height: 100)
                    .background(Color.white)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 3))
                    .shadow(color: Color.black.opacity(0.1), radius: 8, y: 4)

                // Edit badge
                Button(action: {}) {
                    Image(systemName: "pencil")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(SafePathColors.primaryBlue)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
            }

            Text(userName)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(SafePathColors.textPrimary)

            Text(userEmail)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(SafePathColors.textSecondary)

            HStack(spacing: 4) {
                Image(systemName: "location.circle")
                    .font(.system(size: 13))
                    .foregroundColor(SafePathColors.textSecondary)
                Text(userLocation)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(SafePathColors.textSecondary)
            }
        }
    }

    // MARK: - Account Menu Card

    private var accountMenuCard: some View {
        VStack(spacing: 0) {
            menuRow(icon: "person.fill", label: "Edit Profile", action: {})
            Divider().padding(.leading, 52)
            menuRow(icon: "gearshape.fill", label: "Settings", action: {})
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }

    private func menuRow(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(SafePathColors.primaryBlue)
                    .frame(width: 24)
                Text(label)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(SafePathColors.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(SafePathColors.textSecondary.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
    }

    // MARK: - Safety Connections Section

    private var safetyConnectionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("SAFETY CONNECTIONS")

            VStack(spacing: 0) {
                // Emergency Contact Row
                HStack(spacing: 14) {
                    Image(systemName: "cross.case.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(SafePathColors.dangerRed)
                        .frame(width: 40, height: 40)
                        .background(SafePathColors.dangerRed.opacity(0.1))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Emergency Contact")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(SafePathColors.textPrimary)
                        Text("Primary: Sarah Althaf")
                            .font(.system(size: 13))
                            .foregroundColor(SafePathColors.textSecondary)
                    }

                    Spacer()

                    Button("Manage") {}
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(SafePathColors.primaryBlue)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)

                Divider().padding(.leading, 70)

                // Family Group Row
                Button(action: {}) {
                    HStack(spacing: 14) {
                        Image(systemName: "clock.arrow.2.circlepath")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(SafePathColors.primaryBlue)
                            .frame(width: 40, height: 40)
                            .background(SafePathColors.primaryBlue.opacity(0.1))
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Family Group")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(SafePathColors.textPrimary)
                            Text("Althaf Family (4 Members)")
                                .font(.system(size: 13))
                                .foregroundColor(SafePathColors.textSecondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(SafePathColors.textSecondary.opacity(0.5))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
            }
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
        }
    }

    // MARK: - Device Status Section

    private var deviceStatusSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("DEVICE STATUS")

            VStack(spacing: 0) {
                deviceRow(icon: "iphone",        label: "iPhone", isFirst: true)
                Divider().padding(.leading, 52)
                deviceRow(icon: "ipad",          label: "iPad")
                Divider().padding(.leading, 52)
                deviceRow(icon: "applewatch",    label: "Watch")
            }
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
        }
    }

    private func deviceRow(icon: String, label: String, isFirst: Bool = false) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .light))
                .foregroundColor(SafePathColors.textPrimary)
                .frame(width: 24)
            Text(label)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(SafePathColors.textPrimary)
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 22))
                .foregroundColor(SafePathColors.safeGreen)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
    }

    // MARK: - Logout Button

    private var logoutButton: some View {
        Button(action: { showLogoutConfirm = true }) {
            HStack(spacing: 10) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 16, weight: .semibold))
                Text("Logout")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .foregroundColor(SafePathColors.dangerRed)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.white)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(SafePathColors.dangerRed.opacity(0.6), lineWidth: 1.5)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
        }
    }

    // MARK: - Section Label

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(SafePathColors.textSecondary)
            .tracking(0.8)
            .padding(.leading, 4)
    }

    // MARK: - Toast Overlay

    private var toastOverlay: some View {
        VStack {
            Spacer()
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(SafePathColors.safeGreen)
                Text("Logged out successfully")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(red: 0.1, green: 0.15, blue: 0.2))
            .cornerRadius(30)
            .shadow(color: Color.black.opacity(0.2), radius: 10, y: 5)
            .padding(.bottom, 40)
        }
    }
}

#Preview {
    NavigationStack {
        ProfilePageView()
    }
}
