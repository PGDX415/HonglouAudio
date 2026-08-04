//
//  LanternRiddleView.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/8/4.
//

import SwiftUI

struct LanternRiddleView: View {
    @ObservedObject private var theme = ThemeManager.shared
    @State private var riddles: [LanternRiddle] = []
    @State private var currentIndex = 0
    @State private var score = 0
    @State private var selectedAnswer: String? = nil
    @State private var isCorrect: Bool? = nil
    @State private var timeLeft = 15
    @State private var timer: Timer? = nil
    @State private var isGameOver = false
    @State private var isGameStarted = false
    @State private var highScore = UserDefaults.standard.integer(forKey: "lanternRiddle_highScore")
    @State private var answers: [(riddle: LanternRiddle, correct: Bool)] = []
    @State private var showJiaZheng = false

    private let totalRounds = 9

    // Dark lantern aesthetic
    private let lanternRed = Color(red: 0.5, green: 0.08, blue: 0.12)
    private let darkBg = Color(red: 0.08, green: 0.04, blue: 0.06)
    private let goldLight = Color(red: 0.85, green: 0.65, blue: 0.2)
    private let paperWarm = Color(red: 0.92, green: 0.88, blue: 0.78)

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
        .navigationTitle("灯谜会")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { timer?.invalidate() }
    }

    // MARK: - Start

    private var startView: some View {
        ZStack {
            darkBg.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Lantern icon
                ZStack {
                    Circle()
                        .fill(lanternRed.opacity(0.3))
                        .frame(width: 80, height: 80)
                    Text("🏮")
                        .font(.system(size: 40))
                }
                .padding(.bottom, 20)

                Text("灯 谜 会")
                    .font(.system(size: 30, weight: .bold, design: .serif))
                    .foregroundColor(goldLight)
                    .tracking(12)
                    .padding(.bottom, 6)

                Text("第二十二回　听曲文宝玉悟禅机　制灯谜贾政悲谶语")
                    .font(.system(size: 12, design: .serif))
                    .foregroundColor(paperWarm.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 28)

                VStack(spacing: 10) {
                    ruleRow("🏮", "元春省亲后的元宵佳节，贾母命众人制灯谜")
                    ruleRow("📜", "贾政看完众谜，心内愈觉烦闷，大有悲戚之状")
                    ruleRow("💀", "九道灯谜，句句藏着红楼女儿的命运谶语")
                    ruleRow("⏳", "每谜限时 15 秒，猜谜之后揭示谶言")
                }
                .padding(.bottom, 32)

                if highScore > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "trophy.fill")
                            .font(.caption)
                            .foregroundColor(goldLight)
                        Text("最高分：\(highScore)")
                            .font(.system(size: 13, design: .serif))
                            .foregroundColor(goldLight)
                    }
                    .padding(.bottom, 16)
                }

                Button(action: startGame) {
                    Text("入 谜")
                        .font(.system(size: 16, design: .serif))
                        .foregroundColor(darkBg)
                        .frame(width: 140)
                        .padding(.vertical, 12)
                        .background(goldLight)
                        .cornerRadius(20)
                }

                Spacer()
            }
        }
    }

    private func ruleRow(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 8) {
            Text(icon)
                .font(.caption)
            Text(text)
                .font(.system(size: 12, design: .serif))
                .foregroundColor(paperWarm.opacity(0.55))
            Spacer()
        }
        .padding(.horizontal, 50)
    }

    // MARK: - Game

    private var gameView: some View {
        ZStack {
            darkBg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("\(currentIndex + 1)/\(totalRounds)")
                        .font(.system(size: 12, weight: .medium, design: .serif))
                        .foregroundColor(paperWarm.opacity(0.4))

                    Spacer()

                    // Timer
                    HStack(spacing: 4) {
                        Image(systemName: "hourglass")
                            .font(.caption2)
                        Text("\(timeLeft)")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(timeLeft <= 3 ? Color.red : paperWarm.opacity(0.5))
                    .animation(.easeInOut, value: timeLeft)

                    Spacer()

                    Text("\(score)分")
                        .font(.system(size: 12, weight: .medium, design: .serif))
                        .foregroundColor(paperWarm.opacity(0.4))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

                // Timer bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.1)).frame(height: 2)
                        Capsule()
                            .fill(timeLeft <= 3 ? Color.red : goldLight)
                            .frame(width: geo.size.width * CGFloat(timeLeft) / 15, height: 2)
                            .animation(.linear(duration: 1), value: timeLeft)
                    }
                }
                .frame(height: 2)
                .padding(.horizontal, 20)

                Spacer()

                // Character name
                Text("「\(riddles[currentIndex].character)」所作")
                    .font(.system(size: 13, design: .serif))
                    .foregroundColor(goldLight.opacity(0.5))
                    .padding(.bottom, 20)

                // Riddle poem
                Text(riddles[currentIndex].poem)
                    .font(.system(size: 20, design: .serif))
                    .foregroundColor(paperWarm)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 12)

                // Hint
                Text(riddles[currentIndex].hint)
                    .font(.system(size: 13, design: .serif))
                    .foregroundColor(goldLight.opacity(0.5))
                    .padding(.bottom, 28)

                // Options
                VStack(spacing: 8) {
                    ForEach(allOptions(), id: \.self) { option in
                        Button(action: { selectAnswer(option) }) {
                            HStack {
                                Text(option)
                                    .font(.system(size: 16, design: .serif))
                                    .foregroundColor(optionTextColor(option))
                                Spacer()
                                if let selected = selectedAnswer {
                                    if option == riddles[currentIndex].answer {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    } else if option == selected && option != riddles[currentIndex].answer {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            .background(optionBgColor(option))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(optionBorderColor(option), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(selectedAnswer != nil)
                        .padding(.horizontal, 20)
                    }
                }

                Spacer()

                // Prophecy reveal
                if let correct = isCorrect {
                    VStack(spacing: 10) {
                        if correct {
                            HStack(spacing: 4) {
                                Text("🏮")
                                Text("猜中了！")
                                    .font(.system(size: 14, design: .serif))
                                    .foregroundColor(goldLight)
                            }
                        } else {
                            HStack(spacing: 4) {
                                Text("🕯️")
                                Text("谜底是「\(riddles[currentIndex].answer)」")
                                    .font(.system(size: 14, design: .serif))
                                    .foregroundColor(paperWarm.opacity(0.6))
                            }
                        }

                        // The ominous prophecy
                        VStack(spacing: 6) {
                            Text("💀 谶语")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(lanternRed)
                            Text(riddles[currentIndex].prophecy)
                                .font(.system(size: 12, design: .serif))
                                .foregroundColor(paperWarm.opacity(0.55))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .padding(.horizontal, 20)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 4)
                        .background(lanternRed.opacity(0.08))
                        .cornerRadius(8)

                        // Jia Zheng's reaction
                        Button(action: { withAnimation { showJiaZheng.toggle() } }) {
                            HStack(spacing: 4) {
                                Image(systemName: showJiaZheng ? "chevron.up" : "chevron.down")
                                    .font(.caption2)
                                Text("贾政阅后")
                                    .font(.system(size: 11, design: .serif))
                            }
                            .foregroundColor(paperWarm.opacity(0.35))
                        }
                        .buttonStyle(PlainButtonStyle())

                        if showJiaZheng {
                            Text(riddles[currentIndex].jiaZhengReaction)
                                .font(.system(size: 11, design: .serif))
                                .foregroundColor(paperWarm.opacity(0.4))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .padding(.horizontal, 16)
                                .transition(.opacity)
                        }
                    }
                    .padding(.vertical, 10)
                }

                Spacer().frame(height: 16)
            }
        }
    }

    // MARK: - Game Over

    private var gameOverView: some View {
        ZStack {
            darkBg.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Text("🏮")
                    .font(.system(size: 44))
                    .padding(.bottom, 10)

                Text("灯谜会终")
                    .font(.system(size: 20, weight: .bold, design: .serif))
                    .foregroundColor(goldLight)
                    .padding(.bottom, 16)

                // Stats
                HStack(spacing: 20) {
                    statBlock(value: "\(score)", label: "得分", color: goldLight)
                    statBlock(value: "\(answers.filter(\.correct).count)/\(totalRounds)", label: "猜中", color: .green)
                }
                .padding(.bottom, 10)

                if score > highScore && score > 0 {
                    Text("🏮 新纪录")
                        .font(.system(size: 14, weight: .bold, design: .serif))
                        .foregroundColor(goldLight)
                        .padding(.bottom, 16)
                }

                // Quote from the novel
                Text("贾政看完，心内愈觉烦闷，\n大有悲戚之状，回至房中只是思索，\n翻来覆去竟难成寐。")
                    .font(.system(size: 12, design: .serif))
                    .foregroundColor(paperWarm.opacity(0.35))
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)

                // Answer review
                ScrollView {
                    VStack(spacing: 4) {
                        ForEach(Array(answers.enumerated()), id: \.offset) { i, a in
                            HStack(spacing: 8) {
                                Image(systemName: a.correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(a.correct ? .green : .red)
                                    .font(.caption)

                                VStack(alignment: .leading, spacing: 1) {
                                    Text("「\(a.riddle.character)」→ \(a.riddle.answer)")
                                        .font(.system(size: 12, design: .serif))
                                        .foregroundColor(paperWarm.opacity(0.6))
                                    Text(a.riddle.poem.components(separatedBy: "\n").first ?? "")
                                        .font(.system(size: 10, design: .serif))
                                        .foregroundColor(paperWarm.opacity(0.3))
                                        .lineLimit(1)
                                }

                                Spacer()
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.04))
                            .cornerRadius(6)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .frame(maxHeight: 200)
                .padding(.bottom, 16)

                Button(action: startGame) {
                    Text("再入谜")
                        .font(.system(size: 14, design: .serif))
                        .foregroundColor(darkBg)
                        .frame(width: 120)
                        .padding(.vertical, 10)
                        .background(goldLight)
                        .cornerRadius(18)
                }
                .padding(.bottom, 30)

                Spacer()
            }
        }
    }

    private func statBlock(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 11, design: .serif))
                .foregroundColor(paperWarm.opacity(0.3))
        }
        .frame(width: 80)
    }

    // MARK: - Helpers

    private func allOptions() -> [String] {
        let riddle = riddles[currentIndex]
        return ([riddle.answer] + riddle.wrongOptions).shuffled()
    }

    private func optionTextColor(_ option: String) -> Color {
        guard let selected = selectedAnswer else { return paperWarm.opacity(0.8) }
        let correct = riddles[currentIndex].answer
        if option == correct { return .green }
        if option == selected && option != correct { return .red }
        return paperWarm.opacity(0.3)
    }

    private func optionBgColor(_ option: String) -> Color {
        guard let selected = selectedAnswer else { return Color.white.opacity(0.06) }
        let correct = riddles[currentIndex].answer
        if option == correct { return Color.green.opacity(0.1) }
        if option == selected && option != correct { return Color.red.opacity(0.1) }
        return Color.white.opacity(0.06)
    }

    private func optionBorderColor(_ option: String) -> Color {
        guard let selected = selectedAnswer else { return Color.white.opacity(0.08) }
        let correct = riddles[currentIndex].answer
        if option == correct { return Color.green.opacity(0.3) }
        if option == selected && option != correct { return Color.red.opacity(0.3) }
        return Color.white.opacity(0.08)
    }

    // MARK: - Actions

    private func startGame() {
        riddles = LanternRiddleStore.gameRound()
        currentIndex = 0
        score = 0
        selectedAnswer = nil
        isCorrect = nil
        isGameOver = false
        isGameStarted = true
        showJiaZheng = false
        answers = []
        startTimer()
    }

    private func selectAnswer(_ answer: String) {
        guard selectedAnswer == nil else { return }
        selectedAnswer = answer
        timer?.invalidate()

        let correct = answer == riddles[currentIndex].answer
        isCorrect = correct
        showJiaZheng = false
        answers.append((riddles[currentIndex], correct))

        if correct {
            let timeBonus = timeLeft > 5 ? timeLeft - 5 : 0
            score += 10 + timeBonus
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            if currentIndex < totalRounds - 1 {
                currentIndex += 1
                selectedAnswer = nil
                isCorrect = nil
                showJiaZheng = false
                startTimer()
            } else {
                endGame()
            }
        }
    }

    private func startTimer() {
        timer?.invalidate()
        timeLeft = 15
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            if timeLeft > 0 {
                timeLeft -= 1
            } else {
                t.invalidate()
                if selectedAnswer == nil {
                    let riddle = riddles[currentIndex]
                    selectedAnswer = "__timeout__"
                    isCorrect = false
                    showJiaZheng = false
                    answers.append((riddle, false))

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        if currentIndex < totalRounds - 1 {
                            currentIndex += 1
                            selectedAnswer = nil
                            isCorrect = nil
                            startTimer()
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
            UserDefaults.standard.set(highScore, forKey: "lanternRiddle_highScore")
        }
    }
}

#Preview {
    NavigationStack {
        LanternRiddleView()
    }
}
