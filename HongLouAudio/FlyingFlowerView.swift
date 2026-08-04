//
//  FlyingFlowerView.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/8/4.
//

import SwiftUI

struct FlyingFlowerView: View {
    @ObservedObject private var theme = ThemeManager.shared
    @State private var rounds: [(couplet: Couplet, options: [String])] = []
    @State private var currentIndex = 0
    @State private var score = 0
    @State private var streak = 0
    @State private var bestStreak = 0
    @State private var selectedOption: String? = nil
    @State private var isCorrect: Bool? = nil
    @State private var timeLeft = 8
    @State private var timer: Timer? = nil
    @State private var isGameOver = false
    @State private var isGameStarted = false
    @State private var highScore = UserDefaults.standard.integer(forKey: "flyingFlower_highScore")
    @State private var showResult = false
    @State private var resultOpacity: Double = 1
    @State private var answers: [(correct: Bool, couplet: Couplet)] = []

    private let totalRounds = 10

    // Ink painting colors
    private let ink = Color(red: 0.15, green: 0.1, blue: 0.06)
    private let gold = Color(red: 0.75, green: 0.55, blue: 0.35)
    private let ricePaper = Color(red: 0.96, green: 0.93, blue: 0.86)

    var body: some View {
        Group {
            if !isGameStarted {
                startView
            } else if isGameOver {
                gameOverView
            } else {
                gameView
            }
        }
        .navigationTitle("飞花令")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { timer?.invalidate() }
    }

    // MARK: - Start

    private var startView: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("🌸")
                .font(.system(size: 56))
                .padding(.bottom, 16)

            Text("飞 花 令")
                .font(.system(size: 32, weight: .bold, design: .serif))
                .foregroundColor(ink)
                .tracking(10)
                .padding(.bottom, 8)

            Text("红楼诗词接龙")
                .font(.system(size: 14, design: .serif))
                .foregroundColor(ink.opacity(0.5))
                .padding(.bottom, 32)

            VStack(spacing: 12) {
                ruleRow("1", "给出诗句的上半句")
                ruleRow("2", "在 8 秒内选出正确的下半句")
                ruleRow("3", "连续答对获得连击加分")
                ruleRow("4", "共 10 题，答错显示出处")
            }
            .padding(.bottom, 36)

            // High score
            if highScore > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "trophy.fill")
                        .font(.caption)
                        .foregroundColor(gold)
                    Text("最高分：\(highScore)")
                        .font(.system(size: 13, design: .serif))
                        .foregroundColor(gold)
                }
                .padding(.bottom, 20)
            }

            Button(action: startGame) {
                Text("开始接龙")
                    .font(.system(size: 16, design: .serif))
                    .foregroundColor(.white)
                    .frame(width: 160)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.55, green: 0.2, blue: 0.25), Color(red: 0.4, green: 0.1, blue: 0.15)],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .cornerRadius(22)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(ricePaper.ignoresSafeArea())
    }

    private func ruleRow(_ num: String, _ text: String) -> some View {
        HStack(spacing: 10) {
            Text(num)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(ink.opacity(0.6))
                .clipShape(Circle())
            Text(text)
                .font(.system(size: 14, design: .serif))
                .foregroundColor(ink.opacity(0.7))
            Spacer()
        }
        .padding(.horizontal, 60)
    }

    // MARK: - Game

    private var gameView: some View {
        let round = rounds[currentIndex]
        return VStack(spacing: 0) {
            // Header
            HStack {
                // Question counter
                Text("\(currentIndex + 1)/\(totalRounds)")
                    .font(.system(size: 12, weight: .medium, design: .serif))
                    .foregroundColor(ink.opacity(0.4))

                Spacer()

                // Streak
                if streak > 1 {
                    HStack(spacing: 3) {
                        Image(systemName: "flame.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                        Text("\(streak)连击")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.orange)
                    }
                }

                Spacer()

                // Timer
                HStack(spacing: 4) {
                    Image(systemName: "hourglass")
                        .font(.caption2)
                    Text("\(timeLeft)")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(timeLeft <= 2 ? Color.red : ink.opacity(0.5))
                .animation(.easeInOut, value: timeLeft)

                Spacer()

                // Score
                Text("\(score)分")
                    .font(.system(size: 12, weight: .medium, design: .serif))
                    .foregroundColor(ink.opacity(0.4))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            // Timer bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.black.opacity(0.06)).frame(height: 3)
                    Capsule()
                        .fill(timeLeft <= 2 ? Color.red : gold)
                        .frame(width: geo.size.width * CGFloat(timeLeft) / 8, height: 3)
                        .animation(.linear(duration: 1), value: timeLeft)
                }
            }
            .frame(height: 3)
            .padding(.horizontal, 20)

            Spacer()

            // First half of couplet
            VStack(spacing: 4) {
                Text(round.couplet.firstHalf)
                    .font(.system(size: 28, design: .serif))
                    .foregroundColor(ink)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .opacity(resultOpacity)

                Text("________？")
                    .font(.system(size: 20, design: .serif))
                    .foregroundColor(gold.opacity(0.6))
            }
            .padding(.bottom, 32)

            // Options
            VStack(spacing: 10) {
                ForEach(round.options, id: \.self) { option in
                    Button(action: { selectOption(option) }) {
                        HStack {
                            Text(option)
                                .font(.system(size: 16, design: .serif))
                                .foregroundColor(optionTextColor(option))
                                .multilineTextAlignment(.center)
                            Spacer()
                            if selectedOption != nil {
                                if option == round.couplet.secondHalf {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                } else if option == selectedOption && option != round.couplet.secondHalf {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(optionBgColor(option))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(optionBorderColor(option), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(selectedOption != nil)
                    .padding(.horizontal, 20)
                }
            }
            .opacity(resultOpacity)

            Spacer()

            // Result source
            if let correct = isCorrect {
                VStack(spacing: 4) {
                    if correct {
                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                                .font(.caption)
                            Text("\(streak) 连击！+\(10 + streak * 2) 分")
                                .font(.system(size: 13, design: .serif))
                        }
                        .foregroundColor(.orange)
                    } else {
                        VStack(spacing: 6) {
                            Text("出自《\(round.couplet.poemTitle)》")
                                .font(.system(size: 13, design: .serif))
                                .foregroundColor(ink.opacity(0.5))
                            HStack(spacing: 4) {
                                Text("\(round.couplet.author) · 第\(round.couplet.chapterNumber)回")
                                    .font(.system(size: 11, design: .serif))
                                    .foregroundColor(ink.opacity(0.35))
                            }
                        }
                    }
                }
                .padding(.vertical, 16)
            }

            Spacer().frame(height: 20)
        }
        .background(ricePaper.ignoresSafeArea())
    }

    // MARK: - Game Over

    private var gameOverView: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("🏆")
                .font(.system(size: 48))
                .padding(.bottom, 12)

            Text("飞花令结束")
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundColor(ink)
                .padding(.bottom, 20)

            // Score display
            HStack(spacing: 24) {
                statBlock(value: "\(score)", label: "总分", color: gold)
                statBlock(value: "\(bestStreak)", label: "最大连击", color: .orange)
                statBlock(value: "\(answers.filter(\.correct).count)/\(totalRounds)", label: "正确率", color: Color(red: 0.3, green: 0.6, blue: 0.3))
            }
            .padding(.bottom, 12)

            if score > highScore && score > 0 {
                Text("🎉 新纪录！")
                    .font(.system(size: 16, weight: .bold, design: .serif))
                    .foregroundColor(gold)
                    .padding(.bottom, 20)
            }

            // Answer review
            ScrollView {
                VStack(spacing: 6) {
                    ForEach(Array(answers.enumerated()), id: \.offset) { i, a in
                        HStack(spacing: 8) {
                            Image(systemName: a.correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(a.correct ? .green : .red)
                                .font(.caption)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(a.couplet.firstHalf)，\(a.couplet.secondHalf)")
                                    .font(.system(size: 13, design: .serif))
                                    .foregroundColor(ink)
                                    .lineLimit(1)
                                Text("《\(a.couplet.poemTitle)》· \(a.couplet.author)")
                                    .font(.system(size: 10, design: .serif))
                                    .foregroundColor(ink.opacity(0.4))
                            }

                            Spacer()
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.6))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 20)
            }
            .frame(maxHeight: 200)
            .padding(.bottom, 20)

            Button(action: startGame) {
                Text("再来一局")
                    .font(.system(size: 15, design: .serif))
                    .foregroundColor(.white)
                    .frame(width: 140)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.55, green: 0.2, blue: 0.25), Color(red: 0.4, green: 0.1, blue: 0.15)],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .cornerRadius(20)
            }
            .padding(.bottom, 30)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(ricePaper.ignoresSafeArea())
    }

    private func statBlock(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 11, design: .serif))
                .foregroundColor(ink.opacity(0.4))
        }
        .frame(width: 90)
    }

    // MARK: - Option Styling

    private func optionTextColor(_ option: String) -> Color {
        guard let selected = selectedOption else { return ink }
        let correct = rounds[currentIndex].couplet.secondHalf
        if option == correct { return .green }
        if option == selected && option != correct { return .red }
        return ink.opacity(0.4)
    }

    private func optionBgColor(_ option: String) -> Color {
        guard let selected = selectedOption else { return .white.opacity(0.7) }
        let correct = rounds[currentIndex].couplet.secondHalf
        if option == correct { return Color.green.opacity(0.08) }
        if option == selected && option != correct { return Color.red.opacity(0.08) }
        return .white.opacity(0.7)
    }

    private func optionBorderColor(_ option: String) -> Color {
        guard let selected = selectedOption else { return Color.black.opacity(0.08) }
        let correct = rounds[currentIndex].couplet.secondHalf
        if option == correct { return Color.green.opacity(0.4) }
        if option == selected && option != correct { return Color.red.opacity(0.4) }
        return Color.black.opacity(0.08)
    }

    // MARK: - Actions

    private func startGame() {
        rounds = FlyingFlowerStore.gameRound(count: totalRounds)
        currentIndex = 0
        score = 0
        streak = 0
        bestStreak = 0
        selectedOption = nil
        isCorrect = nil
        isGameOver = false
        isGameStarted = true
        resultOpacity = 1
        answers = []
        startTimer()
    }

    private func selectOption(_ option: String) {
        guard selectedOption == nil else { return }
        selectedOption = option
        timer?.invalidate()

        let round = rounds[currentIndex]
        let correct = option == round.couplet.secondHalf

        if correct {
            streak += 1
            bestStreak = max(bestStreak, streak)
            let points = 10 + streak * 2
            score += points
        } else {
            streak = 0
        }

        isCorrect = correct
        answers.append((correct, round.couplet))

        // Advance after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            if currentIndex < totalRounds - 1 {
                withAnimation(.easeInOut(duration: 0.2)) {
                    resultOpacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    currentIndex += 1
                    selectedOption = nil
                    isCorrect = nil
                    withAnimation(.easeInOut(duration: 0.2)) {
                        resultOpacity = 1
                    }
                    startTimer()
                }
            } else {
                endGame()
            }
        }
    }

    private func startTimer() {
        timer?.invalidate()
        timeLeft = 8
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            if timeLeft > 0 {
                timeLeft -= 1
            } else {
                t.invalidate()
                // Time's up — auto fail
                if selectedOption == nil {
                    let round = rounds[currentIndex]
                    streak = 0
                    isCorrect = false
                    answers.append((false, round.couplet))
                    selectedOption = "__timeout__" // prevent double trigger

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                        if currentIndex < totalRounds - 1 {
                            withAnimation(.easeInOut(duration: 0.2)) { resultOpacity = 0 }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                currentIndex += 1
                                selectedOption = nil
                                isCorrect = nil
                                withAnimation { resultOpacity = 1 }
                                startTimer()
                            }
                        } else {
                            endGame()
                        }
                    }
                }
            }
        }
    }

    private func endGame() {
        isGameOver = true
        timer?.invalidate()
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: "flyingFlower_highScore")
        }
    }
}

#Preview {
    NavigationStack {
        FlyingFlowerView()
    }
}
