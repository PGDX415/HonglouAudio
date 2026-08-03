//
//  GardenMapView.swift
//  HongLouAudio
//

import SwiftUI

struct GardenMapView: View {
    @ObservedObject private var theme = ThemeManager.shared
    @State private var selectedLocation: GardenLocation? = nil
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var dragOffset: CGSize = .zero
    @State private var lastDragOffset: CGSize = .zero

    private let mapWidth: CGFloat = 380
    private let mapHeight: CGFloat = 560
    private let minScale: CGFloat = 0.6
    private let maxScale: CGFloat = 2.5

    var body: some View {
        GeometryReader { geo in
            let viewW = geo.size.width
            let viewH = geo.size.height

            ZStack {
                gardenCanvas
                    .frame(width: mapWidth, height: mapHeight)

                ForEach(GardenStore.locations) { location in
                    locationMarker(location)
                }
            }
            .frame(width: mapWidth, height: mapHeight)
            .scaleEffect(scale)
            .offset(x: dragOffset.width, y: dragOffset.height)
            .frame(width: viewW, height: viewH, alignment: .center)
            .clipped()
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        let s = lastScale * value
                        scale = max(minScale, min(s, maxScale))
                    }
                    .onEnded { _ in
                        lastScale = scale
                        let scaledW = mapWidth * scale
                        let scaledH = mapHeight * scale
                        let maxX = max(0, (scaledW - viewW) / 2)
                        let maxY = max(0, (scaledH - viewH) / 2)
                        dragOffset.width = min(max(dragOffset.width, -maxX), maxX)
                        dragOffset.height = min(max(dragOffset.height, -maxY), maxY)
                        lastDragOffset = dragOffset
                    }
            )
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = CGSize(
                            width: lastDragOffset.width + value.translation.width,
                            height: lastDragOffset.height + value.translation.height
                        )
                    }
                    .onEnded { _ in
                        let scaledW = mapWidth * scale
                        let scaledH = mapHeight * scale
                        let maxX = max(0, (scaledW - viewW) / 2)
                        let maxY = max(0, (scaledH - viewH) / 2)
                        dragOffset.width = min(max(dragOffset.width, -maxX), maxX)
                        dragOffset.height = min(max(dragOffset.height, -maxY), maxY)
                        lastDragOffset = dragOffset
                    }
            )
            .background(theme.pageBackground)
        }
        .navigationTitle("大观园")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("重置") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        scale = 1.0
                        lastScale = 1.0
                        dragOffset = .zero
                        lastDragOffset = .zero
                    }
                }
                .font(.caption)
                .foregroundColor(theme.accentRed)
            }
        }
        .sheet(item: $selectedLocation) { location in
            locationDetailSheet(location)
        }
        .overlay(alignment: .bottomTrailing) {
            legendView
                .padding(12)
        }
    }

    // MARK: - Garden Canvas

    private var gardenCanvas: some View {
        ZStack {
            // Base — rice paper
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.96, green: 0.93, blue: 0.86))
                .shadow(radius: 3)

            // Outer wall
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red: 0.35, green: 0.2, blue: 0.1), lineWidth: 2.5)

            // Water features
            waterFeature

            // Garden paths
            gardenPaths

            // Green areas
            greenAreas

            // Central bridge area
            bridgeArea
        }
    }

    private var waterFeature: some View {
        Path { path in
            // Central pond
            path.addEllipse(in: CGRect(x: 120, y: 240, width: 140, height: 100))
            // Connecting stream south
            path.addRect(CGRect(x: 178, y: 330, width: 24, height: 100))
            // West pond
            path.addEllipse(in: CGRect(x: 30, y: 260, width: 70, height: 50))
            // East pond
            path.addEllipse(in: CGRect(x: 280, y: 290, width: 80, height: 60))
        }
        .fill(Color(red: 0.65, green: 0.8, blue: 0.9).opacity(0.45))
    }

    private var gardenPaths: some View {
        Group {
            // Main south-north path
            Path { path in
                path.move(to: CGPoint(x: 190, y: 520))
                path.addLine(to: CGPoint(x: 190, y: 340))
                path.addLine(to: CGPoint(x: 230, y: 280))
                path.addLine(to: CGPoint(x: 230, y: 120))
                path.addLine(to: CGPoint(x: 190, y: 70))
            }
            .stroke(Color(red: 0.35, green: 0.2, blue: 0.1).opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [5, 5]))

            // West path to Xiaoxiang
            Path { path in
                path.move(to: CGPoint(x: 190, y: 340))
                path.addLine(to: CGPoint(x: 70, y: 280))
                path.addLine(to: CGPoint(x: 70, y: 230))
            }
            .stroke(Color(red: 0.35, green: 0.2, blue: 0.1).opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [5, 5]))

            // East path to Yihong
            Path { path in
                path.move(to: CGPoint(x: 230, y: 280))
                path.addLine(to: CGPoint(x: 310, y: 250))
            }
            .stroke(Color(red: 0.35, green: 0.2, blue: 0.1).opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [5, 5]))
        }
    }

    private var greenAreas: some View {
        Group {
            // Northwest bamboo area
            Circle()
                .fill(Color(red: 0.45, green: 0.7, blue: 0.4).opacity(0.25))
                .frame(width: 100, height: 100)
                .position(x: 70, y: 230)

            // Northeast
            Circle()
                .fill(Color(red: 0.4, green: 0.65, blue: 0.35).opacity(0.2))
                .frame(width: 80, height: 80)
                .position(x: 310, y: 240)

            // South greenery
            Ellipse()
                .fill(Color(red: 0.5, green: 0.7, blue: 0.4).opacity(0.15))
                .frame(width: 120, height: 60)
                .position(x: 160, y: 400)
        }
    }

    private var bridgeArea: some View {
        Group {
            // Bridge across central water
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(red: 0.5, green: 0.3, blue: 0.15))
                .frame(width: 50, height: 8)
                .position(x: 190, y: 295)

            // Pavilion on bridge
            Circle()
                .fill(Color(red: 0.75, green: 0.55, blue: 0.3).opacity(0.6))
                .frame(width: 18, height: 18)
                .position(x: 190, y: 285)
        }
    }

    // MARK: - Location Marker

    private func locationMarker(_ location: GardenLocation) -> some View {
        let x = mapWidth * location.position.x
        let y = mapHeight * location.position.y

        return Button(action: {
            selectedLocation = location
        }) {
            VStack(spacing: 2) {
                Image(systemName: location.iconName)
                    .font(.system(size: location.category == .residence ? 16 : 13))
                    .foregroundColor(.white)
                    .frame(width: location.category == .residence ? 30 : 24,
                           height: location.category == .residence ? 30 : 24)
                    .background(location.landmarkColor)
                    .clipShape(Circle())
                    .shadow(color: location.landmarkColor.opacity(0.4), radius: 3)

                Text(location.name)
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(Color(red: 0.25, green: 0.12, blue: 0.05))
                    .lineLimit(1)
                    .fixedSize()
            }
        }
        .buttonStyle(.plain)
        .position(x: x, y: y)
    }

    // MARK: - Detail Sheet

    private func locationDetailSheet(_ location: GardenLocation) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(spacing: 6) {
                    Image(systemName: location.iconName)
                        .font(.system(size: 32))
                        .foregroundColor(location.landmarkColor)
                        .frame(width: 64, height: 64)
                        .background(location.landmarkColor.opacity(0.1))
                        .clipShape(Circle())

                    Text(location.name)
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundColor(theme.primaryText)

                    HStack(spacing: 6) {
                        Image(systemName: "tag")
                            .font(.caption2)
                        Text(location.category.rawValue)
                            .font(.caption)
                    }
                    .foregroundColor(location.landmarkColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(location.landmarkColor.opacity(0.08))
                    .cornerRadius(6)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 8)

                // Residents
                if !location.residents.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("居 住 者")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(location.landmarkColor)
                            .tracking(4)

                        HStack(spacing: 10) {
                            ForEach(location.residents, id: \.self) { name in
                                Text(name)
                                    .font(.system(size: 14, design: .serif))
                                    .foregroundColor(theme.primaryText)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(theme.cardBackground)
                                    .cornerRadius(6)
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }

                Divider()
                    .background(theme.divider)

                // Description
                VStack(alignment: .leading, spacing: 6) {
                    Text("景 致 描 述")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(location.landmarkColor)
                        .tracking(4)

                    Text(location.description)
                        .font(.system(size: 15, design: .serif))
                        .foregroundColor(theme.secondaryText)
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 4)

                // Key Events
                if !location.keyEvents.isEmpty {
                    Divider()
                        .background(theme.divider)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("书 中 故 事")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(location.landmarkColor)
                            .tracking(4)

                        ForEach(Array(location.keyEvents.enumerated()), id: \.offset) { index, event in
                            HStack(alignment: .top, spacing: 10) {
                                Text("\(index + 1).")
                                    .font(.system(size: 13, design: .serif))
                                    .foregroundColor(location.landmarkColor.opacity(0.7))
                                    .frame(width: 18, alignment: .leading)

                                Text(event)
                                    .font(.system(size: 14, design: .serif))
                                    .foregroundColor(theme.primaryText)
                                    .lineSpacing(4)
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }

                Spacer().frame(height: 20)
            }
            .padding(.horizontal, 24)
        }
        .background(theme.pageBackground.ignoresSafeArea())
        .presentationDetents([.medium, .large])
    }

    // MARK: - Legend

    private var legendView: some View {
        VStack(alignment: .leading, spacing: 6) {
            legendItem(color: Color(red: 0.85, green: 0.25, blue: 0.3), label: "居所")
            legendItem(color: Color(red: 0.7, green: 0.5, blue: 0.1), label: "亭台楼阁")
            legendItem(color: Color(red: 0.65, green: 0.1, blue: 0.2), label: "寺庙")
            legendItem(color: Color(red: 0.3, green: 0.6, blue: 0.4), label: "山水景观")
        }
        .padding(10)
        .background(.ultraThinMaterial)
        .cornerRadius(10)
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(theme.primaryText)
        }
    }
}

#Preview {
    NavigationStack {
        GardenMapView()
    }
}
