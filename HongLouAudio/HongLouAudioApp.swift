//
//  HongLouAudioApp.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/3/30.
//

import SwiftUI

@main
struct HongLouAudioApp: App {
    var body: some Scene {
        WindowGroup {
            SplashView()
        }
    }
}

struct MainTabView: View {
    @StateObject private var favoritesManager = FavoritesManager()
    
    var body: some View {
        TabView {
            // Home Tab
            NavigationView {
                ContentView()
            }
            .tabItem {
                Image(systemName: "house")
                Text("主页")
            }
            
            // Favorites Tab
            NavigationView {
                FavoritesView()
            }
            .tabItem {
                Image(systemName: "heart.fill")
                Text("收藏")
            }
            
            // Characters Tab
            NavigationView {
                CharactersView()
            }
            .tabItem {
                Image(systemName: "person.2.fill")
                Text("人物")
            }
            
            // My Account Tab (now includes settings)
            NavigationView {
                MyAccountView()
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("我的")
            }
        }
        .accentColor(Color(red: 0.6, green: 0.2, blue: 0.2)) // Classical red accent
    }
}