//
//  PoetryView.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/8/3.
//

import SwiftUI

struct PoetryView: View {
    @ObservedObject private var theme = ThemeManager.shared
    @State private var selectedCategory: PoemCategory? = nil

    private let store = PoetryStore.self

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    VStack(spacing: 8) {
                        Text("红楼诗词")
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .foregroundColor(theme.deepRed)

                        Text("一场繁华梦，满纸锦绣词")
                            .font(.system(size: 14, design: .serif))
                            .foregroundColor(theme.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16)
                    .padding(.bottom, 20)

                    // Category filter chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            CategoryChip(
                                label: "全部",
                                isSelected: selectedCategory == nil,
                                color: theme.accentRed
                            ) {
                                selectedCategory = nil
                            }

                            ForEach(PoemCategory.allCases, id: \.self) { category in
                                CategoryChip(
                                    label: category.rawValue,
                                    isSelected: selectedCategory == category,
                                    color: category.color
                                ) {
                                    selectedCategory = category
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 16)

                    // Featured poems (only when showing all)
                    if selectedCategory == nil {
                        featuredSection
                    }

                    // Poems list
                    VStack(alignment: .leading, spacing: 0) {
                        let displayPoems = selectedCategory == nil
                            ? store.poems
                            : store.poems.filter { $0.category == selectedCategory }

                        ForEach(Array(displayPoems.enumerated()), id: \.element.id) { index, poem in
                            NavigationLink(destination: PoemDetailView(poem: poem)) {
                                poemRow(poem)
                            }
                            .buttonStyle(PlainButtonStyle())

                            if index < displayPoems.count - 1 {
                                Divider()
                                    .background(theme.divider)
                                    .padding(.leading, 64)
                            }
                        }
                    }
                    .background(theme.cardBackground)
                    .cornerRadius(12)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 24)

                    // Footer
                    Text("共收录 \(store.poems.count) 篇诗词")
                        .font(.caption)
                        .foregroundColor(theme.tertiaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 20)
                }
            }
            .background(
                theme.pageBackground
                    .ignoresSafeArea()
            )
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .accentColor(theme.accentRed)
    }

    // MARK: - Featured Section

    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("名篇推荐")
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundColor(theme.primaryText)
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(store.poems.filter { $0.isFeatured }) { poem in
                        NavigationLink(destination: PoemDetailView(poem: poem)) {
                            featuredCard(poem)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.bottom, 24)
    }

    private func featuredCard(_ poem: Poem) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: poem.category.iconName)
                    .font(.caption)
                    .foregroundColor(poem.category.color)

                Text(poem.category.rawValue)
                    .font(.caption2)
                    .foregroundColor(poem.category.color)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(poem.category.color.opacity(0.1))
            .cornerRadius(6)

            Text(poem.title)
                .font(.system(size: 16, weight: .bold, design: .serif))
                .foregroundColor(theme.primaryText)
                .lineLimit(1)

            Text(poem.author)
                .font(.caption)
                .foregroundColor(theme.secondaryText)

            Text(poem.content)
                .font(.system(size: 11, design: .serif))
                .foregroundColor(theme.tertiaryText)
                .lineLimit(3)
                .frame(width: 140, alignment: .leading)
        }
        .padding(12)
        .frame(width: 170)
        .background(theme.cardBackground)
        .cornerRadius(12)
        .shadow(color: theme.shadowColor, radius: 4, x: 0, y: 2)
    }

    // MARK: - Poem Row

    private func poemRow(_ poem: Poem) -> some View {
        HStack(alignment: .top, spacing: 14) {
            // Category icon
            ZStack {
                Circle()
                    .fill(poem.category.color.opacity(0.1))
                    .frame(width: 40, height: 40)

                Image(systemName: poem.category.iconName)
                    .font(.system(size: 16))
                    .foregroundColor(poem.category.color)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(poem.title)
                        .font(.system(size: 16, weight: .semibold, design: .serif))
                        .foregroundColor(theme.primaryText)

                    if poem.isFeatured {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.1))
                    }
                }

                HStack(spacing: 6) {
                    Text(poem.author)
                        .font(.caption)
                        .foregroundColor(theme.secondaryText)

                    Text("·")
                        .font(.caption)
                        .foregroundColor(theme.tertiaryText)

                    Text("第\(poem.chapterNumber)回")
                        .font(.caption)
                        .foregroundColor(theme.tertiaryText)
                }

                Text(poem.content)
                    .font(.system(size: 12, design: .serif))
                    .foregroundColor(theme.tertiaryText)
                    .lineLimit(2)
                    .padding(.top, 2)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(theme.tertiaryText)
                .padding(.top, 10)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Category Chip

struct CategoryChip: View {
    let label: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : color)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? color : color.opacity(0.1))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Poem Detail View

struct PoemDetailView: View {
    @ObservedObject private var theme = ThemeManager.shared
    let poem: Poem
    @State private var showFullAppreciation = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 0) {
                // Header
                VStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(poem.category.color.opacity(0.08))
                            .frame(width: 72, height: 72)

                        Image(systemName: poem.category.iconName)
                            .font(.system(size: 30))
                            .foregroundColor(poem.category.color)
                    }

                    Text(poem.title)
                        .font(.system(size: 26, weight: .bold, design: .serif))
                        .foregroundColor(theme.primaryText)
                        .multilineTextAlignment(.center)

                    HStack(spacing: 8) {
                        Label(poem.author, systemImage: "person.fill")
                            .font(.caption)
                            .foregroundColor(theme.secondaryText)

                        Text("·")
                            .foregroundColor(theme.tertiaryText)

                        Label("第\(poem.chapterNumber)回", systemImage: "book.closed.fill")
                            .font(.caption)
                            .foregroundColor(theme.secondaryText)
                    }

                    Text(poem.chapterTitle)
                        .font(.caption)
                        .foregroundColor(theme.tertiaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    // Category badge
                    HStack(spacing: 4) {
                        Image(systemName: poem.category.iconName)
                            .font(.caption2)
                        Text(poem.category.rawValue)
                            .font(.caption2)
                    }
                    .foregroundColor(poem.category.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(poem.category.color.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding(.top, 24)
                .padding(.bottom, 24)

                // Divider
                Rectangle()
                    .fill(theme.divider)
                    .frame(height: 1)
                    .padding(.horizontal, 32)

                // Poem content
                VStack(alignment: .center, spacing: 0) {
                    Text(poem.content)
                        .font(.system(size: 17, design: .serif))
                        .foregroundColor(theme.primaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(8)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 24)
                        .frame(maxWidth: .infinity)
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.readingBackground)
                )
                .padding(.horizontal, 16)
                .padding(.top, 20)

                // Appreciation section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "text.quote")
                            .foregroundColor(theme.accentRed)

                        Text("赏析")
                            .font(.system(size: 18, weight: .bold, design: .serif))
                            .foregroundColor(theme.primaryText)

                        Spacer()

                        Button(action: { showFullAppreciation.toggle() }) {
                            Text(showFullAppreciation ? "收起" : "展开全文")
                                .font(.caption)
                                .foregroundColor(theme.accentRed)
                        }
                    }

                    Text(poem.appreciation)
                        .font(.system(size: 15, design: .serif))
                        .foregroundColor(theme.secondaryText)
                        .lineSpacing(6)
                        .lineLimit(showFullAppreciation ? nil : 6)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.cardBackground)
                )
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 32)
            }
        }
        .background(
            theme.pageBackground
                .ignoresSafeArea()
        )
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // Share poem
                    let shareText = "《\(poem.title)》——\(poem.author)\n\n\(poem.content)"
                    let av = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootVC = windowScene.windows.first?.rootViewController {
                        rootVC.present(av, animated: true)
                    }
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(theme.accentRed)
                }
            }
        }
    }
}

#Preview {
    PoetryView()
}
