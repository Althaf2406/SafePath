//
//  JoinFamilyGroupView.swift
//  SafePath
//
//  Created by student on 29/05/26.
//

import SwiftUI
import Combine

struct JoinFamilyGroupView: View {
    @Environment(\.dismiss) var dismiss
    @State private var inviteCode: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Custom Navigation Bar
            customNavigationBar
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // MARK: - Top Icon
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundColor(SafePathColors.primaryBlue)
                        .frame(width: 80, height: 80)
                        .background(SafePathColors.primaryBlue.opacity(0.15))
                        .clipShape(Circle())
                        .padding(.top, 32)
                    
                    // MARK: - Header Text
                    VStack(spacing: 12) {
                        Text("Join Family Group")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(SafePathColors.textPrimary)
                        
                        Text("Stay connected and keep your loved ones\nsafe with real-time updates.")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(SafePathColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    
                    // MARK: - Input Section
                    VStack(spacing: 16) {
                        TextField("E.G. SAFE-1234", text: $inviteCode)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(SafePathColors.primaryBlue)
                            .multilineTextAlignment(.center)
                            .padding(.vertical, 20)
                            .background(SafePathColors.primaryBlue.opacity(0.15))
                            .cornerRadius(16)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                        
                        Text("Ask your family admin for the invite code")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(SafePathColors.textSecondary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    
                    // MARK: - Action Button
                    Button(action: {
                        // Implementasi logic validasi kode undangan nanti
                        print("Join group with code: \(inviteCode)")
                    }) {
                        Text("Join Group")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(SafePathColors.primaryBlue)
                            .clipShape(Capsule()) // Membuat tombol berbentuk pill sesuai desain
                            .shadow(color: SafePathColors.primaryBlue.opacity(0.25), radius: 8, y: 4)
                    }
                    .padding(.horizontal, 24)
                    
                    // MARK: - Static Feature Cards
                    HStack(spacing: 16) {
                        infoCard(
                            icon: "mappin.circle",
                            iconColor: SafePathColors.primaryBlue,
                            title: "Live Location",
                            subtitle: "See your family on\nthe map."
                        )
                        
                        infoCard(
                            icon: "bell.badge",
                            iconColor: SafePathColors.dangerRed,
                            title: "Smart Alerts",
                            subtitle: "Get notified in\nemergencies."
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                }
                .padding(.bottom, 40)
            }
        }
        .background(SafePathColors.backgroundLight.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Subviews
    
    private var customNavigationBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(SafePathColors.primaryBlue)
            }
            
            Spacer()
            
            Text("SafePath")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(SafePathColors.primaryBlue)
            
            Spacer()
            
            // Dummy view untuk menjaga teks SafePath tetap di tengah (balancing)
            Image(systemName: "arrow.left")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.clear)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(SafePathColors.backgroundLight)
    }
    
    private func infoCard(icon: String, iconColor: Color, title: String, subtitle: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(iconColor)
                .frame(width: 48, height: 48)
                .background(iconColor.opacity(0.15))
                .clipShape(Circle())
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(SafePathColors.textPrimary)
                
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(SafePathColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 8)
        .background(SafePathColors.primaryBlue.opacity(0.1))
        .cornerRadius(16)
    }
}

#Preview {
    JoinFamilyGroupView()
}
