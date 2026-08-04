//
//  PersonalityQuizView.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/8/4.
//

import SwiftUI

struct PersonalityQuizView: View {
    @ObservedObject private var theme = ThemeManager.shared
    @State private var currentQuestion = 0
    @State private var scores: [String: Int] = [:]
    @State private var result: PersonalityResult? = nil
    @State private var showResult = false
    @State private var selectedAnswer: Int? = nil
    @State private var questionOpacity: Double = 1
    @State private var progressAnimate: Bool = false

    private let questions = PersonalityQuizStore.questions
    private let totalQuestions: Int

    init() {
        totalQuestions = PersonalityQuizStore.questions.count
    }

    var body: some View {
        Group {
            if showResult, let result = result {
                resultView(result)
            } else {
                quizView
            }
        }
        .navigationTitle("我像红楼梦里的谁")
        .navigationBarTitleDisplayMode(.inline)
        .background(theme.pageBackground.ignoresSafeArea())
    }

    // MARK: - Quiz View

    private var quizView: some View {
        let q = questions[currentQuestion]
        return VStack(spacing: 0) {
            // Progress bar
            VStack(spacing: 8) {
                HStack {
                    Text("第 \(currentQuestion + 1) / \(totalQuestions) 题")
                        .font(.caption)
                        .foregroundColor(theme.tertiaryText)
                    Spacer()
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(theme.divider).frame(height: 6)
                        Capsule()
                            .fill(Color(red: 0.8, green: 0.35, blue: 0.4))
                            .frame(width: geo.size.width * CGFloat(currentQuestion + 1) / CGFloat(totalQuestions), height: 6)
                            .animation(.easeInOut(duration: 0.4), value: currentQuestion)
                    }
                }
                .frame(height: 6)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 8)

            ScrollView {
                VStack(spacing: 24) {
                    // Question
                    Text(q.question)
                        .font(.system(size: 22, weight: .bold, design: .serif))
                        .foregroundColor(theme.primaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .opacity(questionOpacity)
                        .animation(.easeInOut(duration: 0.3), value: questionOpacity)

                    // Answers
                    VStack(spacing: 12) {
                        ForEach(q.answers) { answer in
                            Button(action: { selectAnswer(answer) }) {
                                HStack {
                                    Text(answer.text)
                                        .font(.system(size: 15, design: .serif))
                                        .foregroundColor(theme.primaryText)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                    if selectedAnswer == answer.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(Color(red: 0.8, green: 0.35, blue: 0.4))
                                    }
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedAnswer == answer.id
                                            ? Color(red: 0.8, green: 0.35, blue: 0.4).opacity(0.08)
                                            : theme.cardBackground)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedAnswer == answer.id
                                            ? Color(red: 0.8, green: 0.35, blue: 0.4).opacity(0.3)
                                            : Color.clear, lineWidth: 1.5)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }

    // MARK: - Result View

    private func resultView(_ r: PersonalityResult) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer().frame(height: 20)

                // Percentage circle
                ZStack {
                    Circle()
                        .stroke(theme.divider, lineWidth: 6)
                        .frame(width: 110, height: 110)

                    Circle()
                        .trim(from: 0, to: CGFloat(r.percentage) / 100)
                        .stroke(r.color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 110, height: 110)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.5), value: showResult)

                    VStack(spacing: 0) {
                        Text("\(r.percentage)%")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(r.color)
                        Text("相似度")
                            .font(.system(size: 10))
                            .foregroundColor(theme.tertiaryText)
                    }
                }
                .padding(.bottom, 16)

                // Character image
                if let uiImage = UIImage(named: r.imageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 90, height: 90)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(r.color, lineWidth: 2))
                        .shadow(color: r.color.opacity(0.3), radius: 8)
                        .padding(.bottom, 12)
                }

                // Name + title
                Text(r.emoji)
                    .font(.system(size: 32))
                    .padding(.bottom, 4)

                Text(r.character)
                    .font(.system(size: 30, weight: .bold, design: .serif))
                    .foregroundColor(theme.primaryText)
                    .padding(.bottom, 4)

                Text(r.title)
                    .font(.system(size: 14, design: .serif))
                    .foregroundColor(r.color)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                    .background(r.color.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.bottom, 20)

                // Description
                Text(r.description)
                    .font(.system(size: 15, design: .serif))
                    .foregroundColor(theme.secondaryText)
                    .lineSpacing(7)
                    .padding(.horizontal, 28)
                    .padding(.bottom, 24)

                // Runner-ups
                runnerUpsView
                    .padding(.bottom, 24)

                // Buttons
                VStack(spacing: 12) {
                    Button(action: { shareResult(r) }) {
                        HStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.up")
                            Text("分享结果")
                        }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(r.color)
                        .cornerRadius(14)
                    }

                    Button(action: { restartQuiz() }) {
                        Text("再测一次")
                            .font(.system(size: 14, design: .serif))
                            .foregroundColor(theme.accentRed)
                    }
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 40)
            }
        }
    }

    private var runnerUpsView: some View {
        let sorted = scores.sorted { $0.value > $1.value }.prefix(4).dropFirst()
        guard !sorted.isEmpty else { return AnyView(EmptyView()) }

        return AnyView(
            VStack(alignment: .leading, spacing: 10) {
                Text("你也有一点像……")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(theme.tertiaryText)
                    .padding(.horizontal, 28)

                ForEach(Array(sorted), id: \.key) { name, score in
                    if let r = PersonalityQuizStore.characterResults[name] {
                        let pct = calculatePercentage(score)
                        HStack(spacing: 10) {
                            Text(r.emoji)
                                .font(.caption)

                            Text(name)
                                .font(.system(size: 13, design: .serif))
                                .foregroundColor(theme.primaryText)

                            Spacer()

                            Text("\(pct)%")
                                .font(.system(size: 11))
                                .foregroundColor(r.color)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(r.color.opacity(0.1))
                                .cornerRadius(6)
                        }
                        .padding(.horizontal, 28)
                    }
                }
            }
        )
    }

    // MARK: - Actions

    private func selectAnswer(_ answer: PersonalityAnswer) {
        selectedAnswer = answer.id

        // Accumulate scores
        for (character, points) in answer.scores {
            scores[character, default: 0] += points
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            if currentQuestion < totalQuestions - 1 {
                withAnimation(.easeInOut(duration: 0.2)) {
                    questionOpacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    currentQuestion += 1
                    selectedAnswer = nil
                    withAnimation(.easeInOut(duration: 0.3)) {
                        questionOpacity = 1
                    }
                }
            } else {
                calculateResult()
            }
        }
    }

    private func calculateResult() {
        guard let winner = scores.max(by: { $0.value < $1.value }) else { return }
        if var base = PersonalityQuizStore.characterResults[winner.key] {
            let maxScore = questions.reduce(0) { $0 + $1.answers.map { $0.scores.values.reduce(0,+) }.max()! }
            let pct = Int(Double(winner.value) / Double(maxScore) * 100)
            base = PersonalityResult(
                character: base.character, emoji: base.emoji, title: base.title,
                percentage: min(pct, 99),
                description: base.description, imageName: base.imageName, color: base.color
            )
            result = base
            withAnimation { showResult = true }
        }
    }

    private func calculatePercentage(_ score: Int) -> Int {
        let maxScore = questions.reduce(0) { $0 + $1.answers.map { $0.scores.values.reduce(0,+) }.max()! }
        return min(Int(Double(score) / Double(maxScore) * 100), 99)
    }

    private func restartQuiz() {
        currentQuestion = 0
        scores = [:]
        result = nil
        showResult = false
        selectedAnswer = nil
        questionOpacity = 1
    }

    private func shareResult(_ r: PersonalityResult) {
        let card = PersonalityShareCard(result: r)
        let cardSize = CGSize(width: 390, height: 560)
        if let image = ShareCardRenderer.render(card, size: cardSize) {
            ShareCardRenderer.share(image: image)
        }
    }
}

// MARK: - Share Card

struct PersonalityShareCard: View {
    let result: PersonalityResult
    private let cardW: CGFloat = 390
    private let cardH: CGFloat = 560
    private let cream = Color(red: 0.96, green: 0.93, blue: 0.86)
    private let ink = Color(red: 0.2, green: 0.1, blue: 0.05)

    var body: some View {
        ZStack {
            cream

            RoundedRectangle(cornerRadius: 0)
                .stroke(result.color.opacity(0.3), lineWidth: 1)
                .padding(12)

            VStack(spacing: 0) {
                Spacer().frame(height: 24)

                Text("我像红楼梦里的谁")
                    .font(.system(size: 13, design: .serif))
                    .foregroundColor(ink.opacity(0.4))
                    .tracking(3)

                // Percentage
                ZStack {
                    Circle()
                        .stroke(result.color.opacity(0.2), lineWidth: 5)
                        .frame(width: 90, height: 90)

                    Circle()
                        .trim(from: 0, to: CGFloat(result.percentage) / 100)
                        .stroke(result.color, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .frame(width: 90, height: 90)
                        .rotationEffect(.degrees(-90))

                    Text("\(result.percentage)%")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(result.color)
                }
                .padding(.bottom, 14)

                Text(result.emoji)
                    .font(.system(size: 36))
                    .padding(.bottom, 4)

                Text(result.character)
                    .font(.system(size: 30, weight: .bold, design: .serif))
                    .foregroundColor(ink)
                    .padding(.bottom, 4)

                Text(result.title)
                    .font(.system(size: 13, design: .serif))
                    .foregroundColor(result.color)
                    .padding(.bottom, 18)

                Text(result.description)
                    .font(.system(size: 12, design: .serif))
                    .foregroundColor(ink.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, 36)

                Spacer()

                Text("红楼聆梦 · 人物测试")
                    .font(.system(size: 9, design: .serif))
                    .foregroundColor(ink.opacity(0.3))
                    .tracking(4)
                    .padding(.bottom, 24)
            }
        }
        .frame(width: cardW, height: cardH)
    }
}

#Preview {
    NavigationStack {
        PersonalityQuizView()
    }
}
