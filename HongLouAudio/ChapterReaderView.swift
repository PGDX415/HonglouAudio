//
//  ChapterReaderView.swift
//  HongLouAudio
//

import SwiftUI

struct ChapterReaderView: View {
    let chapter: Chapter

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(chapter.chapterText)
                    .font(.system(size: 18))
                    .foregroundColor(Color(red: 0.15, green: 0.08, blue: 0.05))
                    .lineSpacing(8)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background(
            Color(red: 0.99, green: 0.97, blue: 0.93)
                .ignoresSafeArea()
        )
        .navigationTitle(chapter.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
