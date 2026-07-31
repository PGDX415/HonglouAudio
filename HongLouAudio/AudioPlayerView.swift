import SwiftUI
import AVFoundation
import MediaPlayer
import UIKit
import Combine

struct AudioPlayerView: View {
    @ObservedObject private var audioManager = AudioManager.shared
    @State private var showText = false
    @State private var showSleepTimer = false
    let chapter: Chapter

    /// Parse the title to extract [chapterLabel, clause1, clause2, part]
    private var titleParts: [String] {
        let parts = chapter.title.components(separatedBy: " ")
        return parts  // ["第一回", "甄士隐梦幻识通灵", "贾雨村风尘怀闺秀", "上"]
    }

    private var chapterLabel: String {
        titleParts.first ?? ""
    }

    private var partSuffix: String {
        titleParts.last ?? ""
    }

    private var titleClauses: [String] {
        guard titleParts.count >= 4 else { return [] }
        return Array(titleParts[1..<3])  // [clause1, clause2]
    }

    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.96, blue: 0.92)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Chapter title
                VStack(spacing: 2) {
                    if titleClauses.count >= 2 {
                        // Chapter label + part (e.g., "第一回 · 上")
                        HStack(spacing: 2) {
                            Text(chapterLabel)
                            Text("·")
                            Text(partSuffix)
                        }
                        .font(showText ? .caption2 : .caption)
                        .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.2))

                        // Two clauses on separate lines
                        Text(titleClauses[0])
                            .font(showText ? .callout : .title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 0.2, green: 0.1, blue: 0.1))
                        Text(titleClauses[1])
                            .font(showText ? .callout : .title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 0.2, green: 0.1, blue: 0.1))
                    } else {
                        Text(chapter.title)
                            .font(showText ? .caption : .title3)
                            .fontWeight(showText ? .medium : .bold)
                            .foregroundColor(Color(red: 0.2, green: 0.1, blue: 0.1))
                            .multilineTextAlignment(.center)
                    }
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.top, showText ? 6 : 12)
                .padding(.bottom, showText ? 2 : 4)

                // Play mode & sleep timer controls
                HStack(spacing: 16) {
                    // Play mode toggle
                    Button(action: { audioManager.togglePlayMode() }) {
                        HStack(spacing: 4) {
                            Image(systemName: audioManager.playMode.iconName)
                            Text(audioManager.playMode.label)
                        }
                        .font(showText ? .caption2 : .caption)
                        .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.2))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.92, green: 0.88, blue: 0.80))
                        )
                    }

                    // Sleep timer button
                    Button(action: { showSleepTimer = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: audioManager.sleepTimerActive ? "moon.zzz.fill" : "moon.zzz")
                            if audioManager.sleepTimerActive {
                                Text(formatTime(audioManager.sleepTimerRemaining))
                            } else {
                                Text("定时")
                            }
                        }
                        .font(showText ? .caption2 : .caption)
                        .foregroundColor(audioManager.sleepTimerActive
                            ? Color(red: 0.6, green: 0.2, blue: 0.2)
                            : Color(red: 0.5, green: 0.3, blue: 0.2))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.92, green: 0.88, blue: 0.80))
                        )
                    }
                }
                .padding(.bottom, showText ? 4 : 8)

                // Summary (compact)
                if !showText {
                    Text(chapter.summary)
                        .font(.subheadline)
                        .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.2))
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                }

                // "边听边看" toggle + chapter text
                if !chapter.chapterText.isEmpty {
                    Button(action: { showText.toggle() }) {
                        HStack(spacing: 6) {
                            Image(systemName: showText ? "book.closed.fill" : "book.fill")
                            Text(showText ? "收起正文" : "边听边看")
                        }
                        .font(.subheadline)
                        .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.2))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(red: 0.92, green: 0.88, blue: 0.80))
                        )
                    }
                    .padding(.bottom, showText ? 8 : 0)

                    if showText {
                        ScrollView {
                            Text(chapter.chapterText)
                                .font(.system(size: 17))
                                .foregroundColor(Color(red: 0.15, green: 0.08, blue: 0.05))
                                .lineSpacing(7)
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 20)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.99, green: 0.97, blue: 0.93))
                                .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
                        )
                        .padding(.horizontal, 10)
                        .frame(maxHeight: .infinity)
                    }
                }

                Spacer(minLength: showText ? 10 : 20)

                // Time labels
                HStack {
                    Text(formatTime(audioManager.currentTime))
                        .font(showText ? .caption2 : .caption)
                        .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.2))
                    Spacer()
                    Text(formatTime(audioManager.duration))
                        .font(showText ? .caption2 : .caption)
                        .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.2))
                }
                .padding(.horizontal, showText ? 16 : 24)

                // Progress slider
                Slider(
                    value: $audioManager.progress,
                    in: 0...1,
                    onEditingChanged: { editing in
                        if !editing {
                            audioManager.seek(to: audioManager.progress)
                        }
                    }
                )
                .tint(Color(red: 0.6, green: 0.2, blue: 0.2))
                .padding(.horizontal, showText ? 12 : 20)

                // Control buttons
                HStack(spacing: showText ? 28 : 40) {
                    Button(action: { audioManager.rewind(seconds: 10) }) {
                        Image(systemName: "gobackward.10")
                            .font(showText ? .body : .title2)
                            .foregroundColor(Color(red: 0.2, green: 0.1, blue: 0.1))
                            .padding(showText ? 10 : 15)
                            .background(Color(red: 0.92, green: 0.88, blue: 0.80))
                            .clipShape(Circle())
                    }

                    Button(action: { audioManager.togglePlayPause(for: chapter.audioFileName) }) {
                        Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                            .font(showText ? .system(size: 22) : .system(size: 30))
                            .foregroundColor(.white)
                            .padding(showText ? 14 : 20)
                            .background(
                                Circle()
                                    .fill(audioManager.isPlaying ? Color(red: 0.7, green: 0.3, blue: 0.3) : Color(red: 0.6, green: 0.2, blue: 0.2))
                                    .shadow(color: Color(red: 0.2, green: 0.1, blue: 0.1).opacity(0.3), radius: 5, x: 0, y: 3)
                            )
                    }

                    Button(action: { audioManager.forward(seconds: 10) }) {
                        Image(systemName: "goforward.10")
                            .font(showText ? .body : .title2)
                            .foregroundColor(Color(red: 0.2, green: 0.1, blue: 0.1))
                            .padding(showText ? 10 : 15)
                            .background(Color(red: 0.92, green: 0.88, blue: 0.80))
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom, showText ? 8 : 30)
            }
        }
        .onAppear {
            audioManager.loadAudio(for: chapter.audioFileName, title: chapter.title)
        }
        .sheet(isPresented: $showSleepTimer) {
            sleepTimerSheet
        }
    }

    private var sleepTimerSheet: some View {
        VStack(spacing: 0) {
            // Title
            Text("睡眠定时")
                .font(.headline)
                .foregroundColor(Color(red: 0.2, green: 0.1, blue: 0.1))
                .padding(.top, 24)
                .padding(.bottom, 20)

            // Timer options
            let options: [(Int, String)] = [
                (15, "15 分钟"),
                (30, "30 分钟"),
                (45, "45 分钟"),
                (60, "60 分钟"),
                (0, "关闭定时")
            ]

            ForEach(options, id: \.0) { option in
                Button(action: {
                    if option.0 == 0 {
                        audioManager.cancelSleepTimer()
                    } else {
                        audioManager.setSleepTimer(minutes: option.0)
                    }
                    showSleepTimer = false
                }) {
                    HStack {
                        Text(option.1)
                            .font(.body)
                            .foregroundColor(Color(red: 0.2, green: 0.1, blue: 0.1))
                        Spacer()
                        if (option.0 == 0 && !audioManager.sleepTimerActive)
                            || (audioManager.sleepTimerActive && Int(audioManager.sleepTimerTotal) / 60 == option.0) {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color(red: 0.6, green: 0.2, blue: 0.2))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                }
                Divider().padding(.leading, 24)
            }
        }
        .background(
            Color(red: 0.98, green: 0.96, blue: 0.92).ignoresSafeArea()
        )
        .presentationDetents([.medium])
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

enum PlayMode: CaseIterable {
    case single
    case loop

    var label: String {
        switch self {
        case .single: return "单回"
        case .loop: return "循环"
        }
    }

    var iconName: String {
        switch self {
        case .single: return "arrow.right.to.line"
        case .loop: return "repeat.1"
        }
    }

    var next: PlayMode {
        let cases = PlayMode.allCases
        let idx = cases.firstIndex(of: self)!
        return cases[(idx + 1) % cases.count]
    }
}

class AudioManager: NSObject, ObservableObject {
    static let shared = AudioManager()

    private let player: AVPlayer
    private var playerItem: AVPlayerItem?
    private var timeObserver: Any?
    private var sleepTimer: Timer?
    private var currentTitle: String = ""

    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var progress: Float = 0
    @Published var playMode: PlayMode = .single
    @Published var sleepTimerRemaining: TimeInterval = 0
    @Published var sleepTimerActive: Bool = false
    var sleepTimerTotal: TimeInterval = 0

    private override init() {
        player = AVPlayer()
        player.automaticallyWaitsToMinimizeStalling = false
        super.init()
        configureAudioSession()
        setupInterruptionNotification()
        setupRemoteCommandCenter()
    }

    deinit {
        removeTimeObserver()
        player.pause()
        sleepTimer?.invalidate()
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }

        UIApplication.shared.beginReceivingRemoteControlEvents()
    }

    private func setupInterruptionNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioSessionInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
    }

    @objc private func handleAudioSessionInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        switch type {
        case .began:
            pause()
        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                do {
                    try AVAudioSession.sharedInstance().setActive(true)
                    play()
                } catch {
                    print("Failed to reactivate audio session: \(error)")
                }
            }
        @unknown default:
            break
        }
    }

    func loadAudio(for fileName: String, title: String = "") {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: nil) else {
            print("Audio file not found: \(fileName)")
            return
        }

        // Stop current playback
        player.pause()
        removeTimeObserver()
        NotificationCenter.default.removeObserver(
            self,
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )

        currentTitle = title
        currentTime = 0
        duration = 0
        progress = 0
        isPlaying = false

        let asset = AVURLAsset(url: url)
        playerItem = AVPlayerItem(asset: asset)
        player.replaceCurrentItem(with: playerItem)

        // Observe duration
        playerItem?.asset.loadValuesAsynchronously(forKeys: ["duration"]) { [weak self] in
            DispatchQueue.main.async {
                guard let self = self, let item = self.playerItem else { return }
                let seconds = CMTimeGetSeconds(item.asset.duration)
                if seconds.isFinite && seconds > 0 {
                    self.duration = seconds
                    self.updateNowPlayingInfo()
                }
            }
        }

        // Observe end of playback
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )

        // Periodic time observer
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            let seconds = CMTimeGetSeconds(time)
            if seconds.isFinite {
                self.currentTime = seconds
                self.progress = self.duration > 0 ? Float(seconds / self.duration) : 0
                self.updateNowPlayingInfo()
            }
        }

        updateNowPlayingInfo()
    }

    @objc private func playerDidFinishPlaying() {
        DispatchQueue.main.async {
            if self.playMode == .loop {
                self.player.seek(to: .zero)
                self.currentTime = 0
                self.progress = 0
                self.player.play()
                self.isPlaying = true
                self.updateNowPlayingInfo()
            } else {
                self.player.seek(to: .zero)
                self.isPlaying = false
                self.currentTime = 0
                self.progress = 0
                self.updateNowPlayingInfo()
            }
        }
    }

    private func removeTimeObserver() {
        if let observer = timeObserver {
            player.removeTimeObserver(observer)
            timeObserver = nil
        }
    }

    private func updateNowPlayingInfo() {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = currentTitle
        nowPlayingInfo[MPMediaItemPropertyArtist] = "红楼梦"
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.play()
            return .success
        }

        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }

        commandCenter.skipForwardCommand.preferredIntervals = [10]
        commandCenter.skipForwardCommand.addTarget { [weak self] _ in
            self?.forward(seconds: 10)
            return .success
        }

        commandCenter.skipBackwardCommand.preferredIntervals = [10]
        commandCenter.skipBackwardCommand.addTarget { [weak self] _ in
            self?.rewind(seconds: 10)
            return .success
        }

        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent,
                  let self = self else {
                return .commandFailed
            }
            let time = CMTime(seconds: event.positionTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            self.player.seek(to: time)
            self.currentTime = event.positionTime
            self.progress = self.duration > 0 ? Float(event.positionTime / self.duration) : 0
            self.updateNowPlayingInfo()
            return .success
        }
    }

    func togglePlayPause(for fileName: String) {
        if player.currentItem == nil {
            loadAudio(for: fileName)
        }

        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    func play() {
        // Re-activate audio session every time we play
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to activate audio session: \(error)")
        }
        player.play()
        isPlaying = true
        updateNowPlayingInfo()
    }

    func pause() {
        player.pause()
        isPlaying = false
        updateNowPlayingInfo()
    }

    func rewind(seconds: TimeInterval) {
        let newTime = max(currentTime - seconds, 0)
        let time = CMTime(seconds: newTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.seek(to: time)
        currentTime = newTime
        progress = duration > 0 ? Float(newTime / duration) : 0
    }

    func forward(seconds: TimeInterval) {
        let newTime = min(currentTime + seconds, duration)
        let time = CMTime(seconds: newTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.seek(to: time)
        currentTime = newTime
        progress = duration > 0 ? Float(newTime / duration) : 0
    }

    func seek(to progress: Float) {
        let newTime = TimeInterval(progress) * duration
        let time = CMTime(seconds: newTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.seek(to: time)
        currentTime = newTime
        self.progress = progress

        if isPlaying {
            player.play()
        }
    }

    func togglePlayMode() {
        playMode = playMode.next
    }

    func setSleepTimer(minutes: Int) {
        cancelSleepTimer()
        let seconds = TimeInterval(minutes * 60)
        sleepTimerTotal = seconds
        sleepTimerRemaining = seconds
        sleepTimerActive = true

        sleepTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.sleepTimerRemaining -= 1
            if self.sleepTimerRemaining <= 0 {
                self.sleepTimerRemaining = 0
                self.sleepTimerActive = false
                self.sleepTimer?.invalidate()
                self.sleepTimer = nil
                // Fade out and pause
                self.player.volume = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.pause()
                    self.player.volume = 1.0
                }
            }
        }
    }

    func cancelSleepTimer() {
        sleepTimer?.invalidate()
        sleepTimer = nil
        sleepTimerActive = false
        sleepTimerRemaining = 0
        sleepTimerTotal = 0
    }
}