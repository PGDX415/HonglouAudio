//
//  CacheManagementView.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/8/3.
//

import SwiftUI

struct CacheManagementView: View {
    @ObservedObject private var theme = ThemeManager.shared
    @StateObject private var cacheManager = CacheManager.shared
    @State private var showClearProgressAlert = false
    @State private var showClearBookmarksAlert = false
    @State private var showClearCachesAlert = false
    @State private var showResetAllAlert = false
    @State private var showClearedToast = false
    @State private var toastMessage = ""
    @State private var isRefreshing = false

    var body: some View {
        List {
            // Storage overview
            Section("存储概览") {
                storageRow(
                    icon: "app.bundle.fill",
                    color: theme.accentRed,
                    label: "应用资源（音频+文本）",
                    size: cacheManager.bundleSize,
                    clearable: false
                )

                storageRow(
                    icon: "bookmark.fill",
                    color: .orange,
                    label: "书签数据",
                    size: bookmarkDataSize,
                    clearable: true
                ) {
                    showClearBookmarksAlert = true
                }

                storageRow(
                    icon: "clock.arrow.2.circlepath",
                    color: .blue,
                    label: "播放记录",
                    size: progressDataSize,
                    clearable: true
                ) {
                    showClearProgressAlert = true
                }

                storageRow(
                    icon: "folder.fill",
                    color: .gray,
                    label: "系统缓存",
                    size: cacheManager.cachesSize,
                    clearable: true
                ) {
                    showClearCachesAlert = true
                }

                // Total
                HStack {
                    Spacer()
                    VStack(spacing: 2) {
                        Text("总计")
                            .font(.caption)
                            .foregroundColor(theme.secondaryText)
                        Text(cacheManager.totalSize.formattedSize)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(theme.primaryText)
                    }
                    Spacer()
                }
                .padding(.vertical, 8)
            }

            // Reset all
            Section {
                Button(action: { showResetAllAlert = true }) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text("重置全部数据")
                            .foregroundColor(.red)
                        Spacer()
                    }
                }
                .buttonStyle(PlainButtonStyle())

                Text("将清除所有书签、播放记录、收藏、缓存数据（主题和字体设置不受影响）")
                    .font(.caption)
                    .foregroundColor(theme.tertiaryText)
            }
        }
        .navigationTitle("缓存管理")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(InsetGroupedListStyle())
        .background(
            theme.pageBackground.ignoresSafeArea()
        )
        .alert("清除播放记录？", isPresented: $showClearProgressAlert) {
            Button("取消", role: .cancel) {}
            Button("清除", role: .destructive) {
                cacheManager.clearProgress {
                    toast("播放记录已清除")
                }
            }
        } message: {
            Text("所有章节的播放进度将被重置。")
        }
        .alert("清除书签数据？", isPresented: $showClearBookmarksAlert) {
            Button("取消", role: .cancel) {}
            Button("清除", role: .destructive) {
                cacheManager.clearBookmarks {
                    toast("书签已清除")
                }
            }
        } message: {
            Text("所有章节内的书签将被删除。")
        }
        .alert("清除系统缓存？", isPresented: $showClearCachesAlert) {
            Button("取消", role: .cancel) {}
            Button("清除", role: .destructive) {
                cacheManager.clearCaches {
                    toast("系统缓存已清除")
                }
            }
        } message: {
            Text("清除应用临时缓存文件，不影响使用体验。")
        }
        .alert("重置全部数据？", isPresented: $showResetAllAlert) {
            Button("取消", role: .cancel) {}
            Button("全部重置", role: .destructive) {
                cacheManager.resetAllData {
                    toast("全部数据已重置")
                }
            }
        } message: {
            Text("此操作不可撤销，所有书签、播放记录、收藏将被永久删除。主题和字体设置不受影响。")
        }
        .overlay(alignment: .bottom) {
            if showClearedToast {
                Text(toastMessage)
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.75))
                    .cornerRadius(20)
                    .padding(.bottom, 40)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showClearedToast)
    }

    private func storageRow(
        icon: String,
        color: Color,
        label: String,
        size: Int64,
        clearable: Bool,
        onClear: (() -> Void)? = nil
    ) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)

            Text(label)
                .font(.subheadline)
                .foregroundColor(theme.primaryText)

            Spacer()

            Text(size > 0 ? size.formattedSize : "0 KB")
                .font(.caption)
                .foregroundColor(theme.secondaryText)

            if clearable, let onClear = onClear, size > 0 {
                Button(action: onClear) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(theme.tertiaryText)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.leading, 6)
            }
        }
        .padding(.vertical, 2)
    }

    private var bookmarkDataSize: Int64 {
        let defaults = UserDefaults.standard
        let dict = defaults.dictionaryRepresentation()
        var total: Int64 = 0
        for (key, value) in dict where key.hasPrefix("bookmarks_") {
            if let data = try? JSONSerialization.data(withJSONObject: value) {
                total += Int64(data.count)
            }
        }
        return total
    }

    private var progressDataSize: Int64 {
        let defaults = UserDefaults.standard
        let dict = defaults.dictionaryRepresentation()
        var total: Int64 = 0
        for (key, value) in dict where key.hasPrefix("progress_") {
            if let data = try? JSONSerialization.data(withJSONObject: value) {
                total += Int64(data.count)
            }
        }
        return total
    }

    private func toast(_ message: String) {
        toastMessage = message
        withAnimation { showClearedToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showClearedToast = false }
        }
    }
}

#Preview {
    NavigationStack {
        CacheManagementView()
    }
}
