//
//  QuizView.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/8/4.
//

import SwiftUI

struct QuizView: View {
    @ObservedObject private var theme = ThemeManager.shared
    @State private var questions: [QuizQuestion] = []
    @State private var currentIndex = 0
    @State private var score = 0
    @State private var selectedOption: Int? = nil
    @State private var showExplanation = false
    @State private var isFinished = false
    @State private var answers: [Int] = []  // user's selected indices
    @State private var timeLeft = 30
    @State private var timer: Timer? = nil
    @State private var bestScore = UserDefaults.standard.integer(forKey: "quiz_best_score")
    @Environment(\.dismiss) private var dismiss

    private let totalQuestions = 10

    var body: some View {
        Group {
            if isFinished {
                resultView
            } else if questions.isEmpty {
                loadingView
            } else {
                quizView
            }
        }
        .navigationTitle("红楼知多少")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { startQuiz() }
        .onDisappear { timer?.invalidate() }
    }

    // MARK: - Quiz View

    private var quizView: some View {
        let q = questions[currentIndex]
        return VStack(spacing: 0) {
            // Progress + timer
            HStack {
                Text("第 \(currentIndex + 1) / \(totalQuestions) 题")
                    .font(.caption)
                    .foregroundColor(theme.tertiaryText)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "timer")
                        .font(.caption2)
                    Text("\(timeLeft)s")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(timeLeft <= 5 ? theme.accentRed : theme.secondaryText)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(theme.divider)
                        .frame(height: 4)
                    Capsule()
                        .fill(theme.accentRed)
                        .frame(width: geo.size.width * CGFloat(currentIndex + 1) / CGFloat(totalQuestions), height: 4)
                        .animation(.easeInOut, value: currentIndex)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, 20)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Question
                    Text(q.question)
                        .font(.system(size: 20, weight: .semibold, design: .serif))
                        .foregroundColor(theme.primaryText)
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                        .padding(.bottom, 20)
                        .fixedSize(horizontal: false, vertical: true)

                    // Options
                    ForEach(Array(q.options.enumerated()), id: \.offset) { idx, option in
                        Button(action: { selectOption(idx) }) {
                            HStack(spacing: 12) {
                                // Option letter
                                ZStack {
                                    Circle()
                                        .fill(optionCircleColor(idx))
                                        .frame(width: 32, height: 32)

                                    Text(["甲", "乙", "丙", "丁"][idx])
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(optionTextColor(idx))
                                }

                                Text(option)
                                    .font(.system(size: 15))
                                    .foregroundColor(theme.primaryText)
                                    .multilineTextAlignment(.leading)

                                Spacer()

                                if selectedOption != nil {
                                    if idx == q.correctIndex {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    } else if idx == selectedOption && idx != q.correctIndex {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(theme.accentRed)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(optionBackgroundColor(idx))
                            .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(selectedOption != nil)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)
                    }

                    // Explanation
                    if showExplanation {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 4) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.caption)
                                    .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.1))
                                Text("解析")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(theme.primaryText)
                            }

                            Text(q.explanation)
                                .font(.system(size: 13, design: .serif))
                                .foregroundColor(theme.secondaryText)
                                .lineSpacing(4)
                        }
                        .padding(14)
                        .background(theme.cardBackground)
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                        // Next button
                        Button(action: nextQuestion) {
                            Text(currentIndex < totalQuestions - 1 ? "下一题" : "查看结果")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(theme.accentRed)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    }
                }
                .padding(.bottom, 24)
            }
        }
        .background(theme.pageBackground.ignoresSafeArea())
    }

    // MARK: - Result View

    private var resultView: some View {
        VStack(spacing: 0) {
            Spacer()

            // Score circle
            ZStack {
                Circle()
                    .stroke(theme.divider, lineWidth: 8)
                    .frame(width: 140, height: 140)

                Circle()
                    .trim(from: 0, to: CGFloat(score) / CGFloat(totalQuestions))
                    .stroke(
                        ratingColor,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1), value: isFinished)

                VStack(spacing: 0) {
                    Text("\(score)")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(ratingColor)
                    Text("/ \(totalQuestions)")
                        .font(.caption)
                        .foregroundColor(theme.tertiaryText)
                }
            }
            .padding(.bottom, 16)

            Text(ratingText)
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundColor(theme.primaryText)
                .padding(.bottom, 4)

            if score > bestScore && score > 0 {
                Text("🎉 新纪录！")
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.1))
                    .padding(.bottom, 16)
            } else {
                Text("历史最佳：\(bestScore) / \(totalQuestions)")
                    .font(.caption)
                    .foregroundColor(theme.tertiaryText)
                    .padding(.bottom, 16)
            }

            Spacer()

            // Review answers
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(Array(questions.enumerated()), id: \.element.id) { i, q in
                        HStack(spacing: 8) {
                            Image(systemName: answers[i] == q.correctIndex ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(answers[i] == q.correctIndex ? .green : theme.accentRed)
                                .font(.caption)

                            Text("\(i + 1). \(q.question)")
                                .font(.system(size: 13))
                                .foregroundColor(theme.primaryText)
                                .lineLimit(1)

                            Spacer()
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(theme.cardBackground)
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 20)
            }
            .frame(maxHeight: 240)
            .padding(.bottom, 20)

            // Play again
            Button(action: startQuiz) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.counterclockwise")
                    Text("再来一局")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(theme.accentRed)
                .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .background(theme.pageBackground.ignoresSafeArea())
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("正在出题...")
                .font(.caption)
                .foregroundColor(theme.tertiaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Actions

    private func startQuiz() {
        questions = QuizStore.randomQuiz(count: totalQuestions)
        currentIndex = 0
        score = 0
        selectedOption = nil
        showExplanation = false
        isFinished = false
        answers = Array(repeating: -1, count: totalQuestions)
        startTimer()
    }

    private func selectOption(_ idx: Int) {
        guard selectedOption == nil else { return }
        selectedOption = idx
        timer?.invalidate()

        let q = questions[currentIndex]
        if idx == q.correctIndex {
            score += 1
        }
        answers[currentIndex] = idx

        // Show explanation after short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation { showExplanation = true }
        }
    }

    private func nextQuestion() {
        if currentIndex < totalQuestions - 1 {
            currentIndex += 1
            selectedOption = nil
            showExplanation = false
            startTimer()
        } else {
            finishQuiz()
        }
    }

    private func finishQuiz() {
        isFinished = true
        timer?.invalidate()
        if score > bestScore {
            bestScore = score
            UserDefaults.standard.set(bestScore, forKey: "quiz_best_score")
        }
    }

    private func startTimer() {
        timer?.invalidate()
        timeLeft = 30
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            if timeLeft > 0 {
                timeLeft -= 1
            } else {
                t.invalidate()
                // Auto-select nothing (wrong) when time runs out
                if selectedOption == nil {
                    selectOption(-1)
                    answers[currentIndex] = -1
                }
            }
        }
    }

    // MARK: - Option Styling

    private func optionCircleColor(_ idx: Int) -> Color {
        guard let selected = selectedOption else {
            return theme.cardBackground
        }
        let q = questions[currentIndex]
        if idx == q.correctIndex {
            return Color.green.opacity(0.15)
        }
        if idx == selected && idx != q.correctIndex {
            return theme.accentRed.opacity(0.15)
        }
        return theme.cardBackground
    }

    private func optionTextColor(_ idx: Int) -> Color {
        guard let selected = selectedOption else {
            return theme.accentRed
        }
        let q = questions[currentIndex]
        if idx == q.correctIndex {
            return .green
        }
        if idx == selected && idx != q.correctIndex {
            return theme.accentRed
        }
        return theme.tertiaryText
    }

    private func optionBackgroundColor(_ idx: Int) -> Color {
        guard let selected = selectedOption else {
            return theme.cardBackground
        }
        let q = questions[currentIndex]
        if idx == q.correctIndex {
            return Color.green.opacity(0.08)
        }
        if idx == selected && idx != q.correctIndex {
            return theme.accentRed.opacity(0.08)
        }
        return theme.cardBackground
    }

    // MARK: - Rating

    private var ratingColor: Color {
        let pct = Double(score) / Double(totalQuestions)
        if pct >= 0.8 { return .green }
        if pct >= 0.5 { return Color(red: 0.8, green: 0.6, blue: 0.1) }
        return theme.accentRed
    }

    private var ratingText: String {
        let pct = Double(score) / Double(totalQuestions)
        switch pct {
        case 1.0: return "满腹经纶"
        case 0.8...: return "博学多才"
        case 0.6...: return "初窥门径"
        case 0.4...: return "尚需努力"
        default: return "再读几遍吧"
        }
    }
}

#Preview {
    NavigationStack {
        QuizView()
    }
}
