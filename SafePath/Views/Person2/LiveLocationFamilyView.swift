//
//  LiveLocationFamilyView.swift
//  SafePath
//
//  Created by student on 29/05/26.
//

import SwiftUI
import MapKit

struct LiveLocationFamilyView: View {
    @State private var showBottomSheet = true
    
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -7.2504, longitude: 112.7688),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Custom Top Navigation Bar
            customTopBar
            
            // MARK: - Area Map & Bottom Sheet Overlay
            ZStack(alignment: .bottom) {
                Map(coordinateRegion: $mapRegion)
                    .ignoresSafeArea()
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.yellow.opacity(0.1), Color.brown.opacity(0.2)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                // MARK: - Map Markers (Pins)
                mapPinsLayer
                
                // MARK: - Floating Map Action Buttons
                VStack(spacing: 12) {
                    Button(action: {}) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 20))
                            .foregroundColor(SafePathColors.primaryBlue)
                            .frame(width: 44, height: 44)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.15), radius: 5, y: 3)
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "square.3.layers.3d")
                            .font(.system(size: 18))
                            .foregroundColor(SafePathColors.primaryBlue)
                            .frame(width: 44, height: 44)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .black.opacity(0.15), radius: 5, y: 3)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 16)
                .padding(.top, 16)
                
                // MARK: - Bottom Sheet (Detail Anggota Keluarga)
                if showBottomSheet {
                    memberBottomSheet
                        .transition(.move(edge: .bottom))
                        .padding(.bottom, 0)
                }
            }
        }
        .background(SafePathColors.backgroundLight.ignoresSafeArea())
        .navigationBarHidden(true)
    }
    
    // MARK: - Subviews
    
    private var customTopBar: some View {
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "shield.lefthalf.filled")
                        .foregroundColor(SafePathColors.primaryBlue)
                        .font(.system(size: 24, weight: .bold))
                    Text("SafePath")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(SafePathColors.primaryBlue)
                }
                
                Spacer()
                
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 36, height: 36)
                    .foregroundColor(SafePathColors.textSecondary.opacity(0.5))
                    .clipShape(Circle())
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Color.white)
            
            Divider()
        }
    }
    
    private var mapPinsLayer: some View {
        ZStack {
            VStack(spacing: 6) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 44, height: 44)
                    .foregroundColor(SafePathColors.textSecondary)
                    .background(Color.gray.opacity(0.3))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(SafePathColors.safeGreen, lineWidth: 3))
                    .shadow(radius: 4)
                
                Text("Sarah (Safe)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(SafePathColors.safeGreen)
                    .cornerRadius(12)
            }
            .offset(x: -80, y: -100)
            
            ZStack(alignment: .topTrailing) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(SafePathColors.textSecondary)
                    .background(Color.gray.opacity(0.4))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(radius: 6)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                    .background(SafePathColors.dangerRed)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .offset(x: 4, y: -4)
            }
            .offset(x: 10, y: 15)
        }
    }
    
    private var memberBottomSheet: some View {
        VStack(spacing: 20) {
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 12)
            
            HStack(alignment: .top, spacing: 16) {
                Image(systemName: "person.crop.square.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 64, height: 64)
                    .foregroundColor(.gray)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(SafePathColors.dangerRed, lineWidth: 2)
                    )
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Dzaky")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(SafePathColors.textPrimary)
                    
                    HStack(spacing: 6) {
                        Circle()
                            .fill(SafePathColors.dangerRed)
                            .frame(width: 8, height: 8)
                        Text("NEED HELP")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(SafePathColors.dangerRed)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "battery.50")
                            .font(.system(size: 14))
                        Text("46%")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(SafePathColors.textPrimary)
                    
                    Text("1 min ago")
                        .font(.system(size: 13))
                        .foregroundColor(SafePathColors.textSecondary)
                }
            }
            .padding(.horizontal, 24)
            
            HStack(spacing: 16) {
                Image(systemName: "location.fill")
                    .font(.system(size: 20))
                    .foregroundColor(SafePathColors.primaryBlue)
                    .frame(width: 44, height: 44)
                    .background(SafePathColors.primaryBlue.opacity(0.15))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("LAST LOCATION")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(SafePathColors.textSecondary)
                        .tracking(1)
                    Text("Near Shelter Balai Kota")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(SafePathColors.textPrimary)
                }
                Spacer()
            }
            .padding(16)
            .background(SafePathColors.lightBlueCard)
            .cornerRadius(16)
            .padding(.horizontal, 24)
            
            Button(action: {}) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.turn.up.right")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Navigate to Member")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(SafePathColors.primaryBlue)
                .cornerRadius(14)
            }
            .padding(.horizontal, 24)
            
            HStack(spacing: 16) {
                Button(action: {}) {
                    HStack(spacing: 8) {
                        Image(systemName: "phone")
                            .font(.system(size: 18, weight: .medium))
                        Text("Call")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(SafePathColors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                }
                
                Button(action: {}) {
                    HStack(spacing: 8) {
                        Image(systemName: "message")
                            .font(.system(size: 18, weight: .medium))
                        Text("Send Message")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(SafePathColors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Color.white)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 32,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 32
            )
        )
        .shadow(color: Color.black.opacity(0.15), radius: 20, y: -5)
    }
}

#Preview {
    LiveLocationFamilyView()
}

