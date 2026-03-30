//
//  ContentView.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/3/30.
//

import SwiftUI

struct ContentView: View {
    @State private var chapters: [Chapter] = []
    
    var body: some View {
        NavigationView {
            List(chapters) { chapter in
                NavigationLink(destination: AudioPlayerView(chapter: chapter)) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("\(chapter.number)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color(red: 0.6, green: 0.2, blue: 0.2)) // Classical red
                                .clipShape(Circle())
                            
                            Text(chapter.title)
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(Color(red: 0.2, green: 0.1, blue: 0.1)) // Deep brown
                        }
                        
                        Text(chapter.summary)
                            .font(.caption)
                            .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.2)) // Warm brown
                            .lineLimit(2)
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(Color(red: 0.96, green: 0.94, blue: 0.90)) // Antique paper color
            }
            .navigationTitle("红楼听梦")
            .onAppear {
                chapters = ChapterLoader.loadChapters()
            }
            .listStyle(PlainListStyle())
            .background(
                Color(red: 0.98, green: 0.96, blue: 0.92) // Soft antique paper background
                    .ignoresSafeArea()
            )
        }
        .accentColor(Color(red: 0.6, green: 0.2, blue: 0.2)) // Classical red accent
    }
}

#Preview {
    ContentView()
}
