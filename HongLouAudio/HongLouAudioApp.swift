//
//  HongLouAudioApp.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/3/30.
//

import SwiftUI

@main
struct HongLouAudioApp: App {
    init() {
        // Pre-warm audio session at launch
        _ = AudioManager.shared
    }

    var body: some Scene {
        WindowGroup {
            SplashView()
        }
    }
}

struct MainTabView: View {
    @StateObject private var favoritesManager = FavoritesManager()
    @ObservedObject private var theme = ThemeManager.shared

    var body: some View {
        TabView {
            // Home Tab
            ContentView(favoritesManager: favoritesManager)
            .tabItem {
                Image(systemName: "house")
                Text("主页")
            }

            // Favorites Tab
            NavigationStack {
                FavoritesView(favoritesManager: favoritesManager)
            }
            .tabItem {
                Image(systemName: "heart.fill")
                Text("收藏")
            }

            // Characters Tab
            NavigationStack {
                CharactersView()
            }
            .tabItem {
                Image(systemName: "person.2.fill")
                Text("人物")
            }

            // YaQu Tab
            YaQuView()
                .tabItem {
                    Image(systemName: "text.book.closed.fill")
                    Text("雅趣")
                }

            // My Account Tab (now includes settings)
            NavigationStack {
                MyAccountView()
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("我的")
            }
        }
        .accentColor(theme.accentRed)
        .preferredColorScheme(theme.isDarkMode ? .dark : nil)
    }
}