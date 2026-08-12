import SwiftUI
import AVFoundation
import MediaPlayer
import UIKit
import Combine

struct AudioPlayerView: View {
    @ObservedObject private var audioManager = AudioManager.shared
    @ObservedObject private var theme = ThemeManager.shared
    @State private var showText = false
    @AppStorage("textFontSize") private var textFontSize: Double = 18.0
    @State private var showSleepTimer = false
    @State private var showBookmarks = false
    @State private var showAmbientSounds = false
    @StateObject private var ambientManager = AmbientSoundManager.shared
    @State private var chapter: Chapter


    init(chapter: Chapter, autoPlay: Bool = false) {
        self._chapter = State(initialValue: chapter)
    }

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

    /// Split the chapter text into paragraphs for display
    private var paragraphs: [String] {
        chapter.chapterText
            .components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    /// Find the paragraph index for the current playback time
    private var currentParagraphIndex: Int? {
        guard let timestamps = chapter.paragraphTimestamps,
              !timestamps.isEmpty,
              audioManager.duration > 0 else { return nil }

        for i in (0..<timestamps.count).reversed() {
            if audioManager.currentTime >= timestamps[i] {
                // Make sure this paragraph actually exists
                return i < paragraphs.count ? i : nil
            }
        }
        return nil
    }

    var body: some View {
        ZStack {
            theme.pageBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Chapter title — hidden when viewing text (shown in nav bar instead)
                if !showText {
                    VStack(spacing: 2) {
                    if titleClauses.count >= 2 {
                        // Chapter label + part (e.g., "第一回 · 上")
                        HStack(spacing: 2) {
                            Text(chapterLabel)
                            Text("·")
                            Text(partSuffix)
                        }
                        .font(showText ? .caption2 : .caption)
                        .foregroundColor(theme.tertiaryText)

                        // Two clauses on separate lines
                        Text(titleClauses[0])
                            .font(showText ? .callout : .title3)
                            .fontWeight(.bold)
                            .foregroundColor(theme.primaryText)
                        Text(titleClauses[1])
                            .font(showText ? .callout : .title3)
                            .fontWeight(.bold)
                            .foregroundColor(theme.primaryText)
                    } else {
                        Text(chapter.title)
                            .font(showText ? .caption : .title3)
                            .fontWeight(showText ? .medium : .bold)
                            .foregroundColor(theme.primaryText)
                            .multilineTextAlignment(.center)
                    }
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.top, showText ? 6 : 12)
                .padding(.bottom, 4)
                }  // end if !showText

                // Play mode & sleep timer controls — hidden when viewing text
                if !showText {
                    HStack(spacing: 16) {
                    // Play mode toggle
                    Button(action: { audioManager.togglePlayMode() }) {
                        HStack(spacing: 4) {
                            Image(systemName: audioManager.playMode.iconName)
                            Text(audioManager.playMode.label)
                        }
                        .font(showText ? .caption2 : .caption)
                        .foregroundColor(theme.tertiaryText)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(theme.buttonBackground)
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
                            ? theme.accentRed
                            : theme.tertiaryText)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(theme.buttonBackground)
                        )
                    }

                    // Ambient sound button
                    Button(action: { showAmbientSounds = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: ambientManager.isAmbientEnabled
                                ? "speaker.wave.2.fill"
                                : "speaker.wave.1")
                            Text("雅音")
                        }
                        .font(showText ? .caption2 : .caption)
                        .foregroundColor(ambientManager.isAmbientEnabled
                            ? theme.accentRed
                            : theme.tertiaryText)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(theme.buttonBackground)
                        )
                    }

                }
                .padding(.bottom, showText ? 4 : 8)
                }  // end if !showText

                // Summary (compact)
                if !showText {
                    Text(chapter.summary)
                        .font(.subheadline)
                        .foregroundColor(theme.secondaryText)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                }

                // "边听边看" toggle + chapter text
                if !chapter.chapterText.isEmpty {
                    if !showText {
                        Button(action: { withAnimation { showText = true } }) {
                            HStack(spacing: 6) {
                                Image(systemName: "book.fill")
                                Text("边听边看")
                            }
                            .font(.subheadline)
                            .foregroundColor(theme.tertiaryText)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(theme.buttonBackground)
                            )
                        }
                        .padding(.bottom, 0)
                    }

                    if showText {
                        ScrollViewReader { proxy in
                            ScrollView {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(Array(paragraphs.enumerated()), id: \.offset) { index, paragraph in
                                        Text(paragraph)
                                            .font(.system(size: textFontSize))
                                            .foregroundColor(
                                                currentParagraphIndex == index
                                                    ? theme.accentRed
                                                    : theme.primaryText
                                            )
                                            .lineSpacing(7)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 6)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .id(index)
                                            .background(
                                                currentParagraphIndex == index
                                                    ? theme.accentRed.opacity(0.08)
                                                    : Color.clear
                                            )
                                    }
                                }
                                .padding(.vertical, 20)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(theme.readingBackground)
                                    .shadow(color: theme.shadowColor, radius: 3, x: 0, y: 1)
                            )
                            .padding(.horizontal, 10)
                            .frame(maxHeight: .infinity)
                            .onChange(of: currentParagraphIndex) { _, newIndex in
                                guard let idx = newIndex else { return }
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    proxy.scrollTo(idx, anchor: .center)
                                }
                            }
                        }
                    }
                }

                Spacer(minLength: showText ? 10 : 20)

                // Time labels
                HStack {
                    Text(formatTime(audioManager.currentTime))
                        .font(showText ? .caption2 : .caption)
                        .foregroundColor(theme.secondaryText)
                    Spacer()
                    Text(formatTime(audioManager.duration))
                        .font(showText ? .caption2 : .caption)
                        .foregroundColor(theme.secondaryText)
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
                .tint(theme.accentRed)
                .padding(.horizontal, showText ? 12 : 20)

                // Bookmark controls — below progress bar
                HStack(spacing: 8) {
                    Button(action: {
                        if audioManager.bookmarks.contains(where: { abs($0.time - audioManager.currentTime) < 3 }) {
                            if let bm = audioManager.bookmarks.first(where: { abs($0.time - audioManager.currentTime) < 3 }) {
                                audioManager.removeBookmark(bm)
                            }
                        } else {
                            audioManager.addBookmark()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: audioManager.bookmarks.contains(where: { abs($0.time - audioManager.currentTime) < 3 })
                                ? "bookmark.fill" : "bookmark")
                            Text("书签")
                        }
                        .font(showText ? .caption2 : .caption)
                        .foregroundColor(theme.tertiaryText)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(theme.buttonBackground)
                        )
                    }

                    if !audioManager.bookmarks.isEmpty {
                        Button(action: { showBookmarks = true }) {
                            HStack(spacing: 4) {
                                Image(systemName: "list.bullet.rectangle")
                                Text("\(audioManager.bookmarks.count)")
                            }
                            .font(showText ? .caption2 : .caption)
                            .foregroundColor(theme.tertiaryText)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(theme.buttonBackground)
                            )
                        }
                    }
                }
                .padding(.bottom, showText ? 4 : 8)

                // Control buttons
                HStack(spacing: showText ? 28 : 40) {
                    Button(action: { audioManager.rewind(seconds: 10) }) {
                        Image(systemName: "gobackward.10")
                            .font(showText ? .body : .title2)
                            .foregroundColor(theme.primaryText)
                            .padding(showText ? 10 : 15)
                            .background(theme.buttonBackground)
                            .clipShape(Circle())
                    }

                    Button(action: { audioManager.togglePlayPause(for: chapter.audioFileName) }) {
                        Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                            .font(showText ? .system(size: 22) : .system(size: 30))
                            .foregroundColor(.white)
                            .padding(showText ? 14 : 20)
                            .background(
                                Circle()
                                    .fill(audioManager.isPlaying ? Color(red: 0.7, green: 0.3, blue: 0.3) : theme.accentRed)
                                    .shadow(color: theme.primaryText.opacity(0.3), radius: 5, x: 0, y: 3)
                            )
                    }

                    Button(action: { audioManager.forward(seconds: 10) }) {
                        Image(systemName: "goforward.10")
                            .font(showText ? .body : .title2)
                            .foregroundColor(theme.primaryText)
                            .padding(showText ? 10 : 15)
                            .background(theme.buttonBackground)
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom, showText ? 8 : 30)
            }
        }
        .onAppear {
            audioManager.loadAudio(for: chapter.audioFileName, title: chapter.title, chapterNumber: chapter.number)
            ambientManager.activateAutoPlay()
        }
        .onDisappear {
            ambientManager.deactivateAutoPlay()
        }
        .onChange(of: audioManager.currentPlayingChapter) { oldChapter, newChapter in
            if let newChapter = newChapter, (oldChapter == nil || oldChapter!.number != newChapter.number || oldChapter!.audioFileName != newChapter.audioFileName) {
                chapter = newChapter
                showText = false
            }
        }
        .sheet(isPresented: $showSleepTimer) {
            sleepTimerSheet
        }
        .sheet(isPresented: $showBookmarks) {
            bookmarkListSheet
        }
        .sheet(isPresented: $showAmbientSounds) {
            ambientSoundSheet
        }
        .toolbar {
            if showText, titleClauses.count >= 2 {
                ToolbarItem(placement: .principal) {
                    HStack(alignment: .center, spacing: 4) {
                        Text("\(chapterLabel) · \(partSuffix)")
                            .font(.system(size: 11))
                            .foregroundColor(theme.tertiaryText)
                            .fixedSize()
                        VStack(alignment: .leading, spacing: 0) {
                            Text(titleClauses[0])
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(theme.primaryText)
                            Text(titleClauses[1])
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(theme.primaryText)
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showText.toggle() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(theme.tertiaryText.opacity(0.7))
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var sleepTimerSheet: some View {
        VStack(spacing: 0) {
            // Title
            Text("睡眠定时")
                .font(.headline)
                .foregroundColor(theme.primaryText)
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
                            .foregroundColor(theme.primaryText)
                        Spacer()
                        if (option.0 == 0 && !audioManager.sleepTimerActive)
                            || (audioManager.sleepTimerActive && Int(audioManager.sleepTimerTotal) / 60 == option.0) {
                            Image(systemName: "checkmark")
                                .foregroundColor(theme.accentRed)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                }
                Divider().padding(.leading, 24)
            }
        }
        .background(
            theme.pageBackground.ignoresSafeArea()
        )
        .presentationDetents([.medium])
    }

    @State private var editingBookmark: Bookmark? = nil
    @State private var editLabel: String = ""

    private var bookmarkListSheet: some View {
        VStack(spacing: 0) {
            Text("书签")
                .font(.headline)
                .foregroundColor(theme.primaryText)
                .padding(.top, 24)
                .padding(.bottom, 16)

            if audioManager.bookmarks.isEmpty {
                Spacer()
                Text("暂无书签")
                    .foregroundColor(theme.secondaryText)
                Spacer()
            } else {
                List {
                    ForEach(audioManager.bookmarks) { bookmark in
                        HStack {
                            Button(action: {
                                audioManager.seekToBookmark(bookmark)
                                showBookmarks = false
                            }) {
                                HStack {
                                    Image(systemName: "bookmark.fill")
                                        .foregroundColor(theme.accentRed)
                                    Text(bookmark.label)
                                        .font(.body)
                                        .foregroundColor(theme.primaryText)
                                    Spacer()
                                }
                            }

                            Button(action: {
                                editingBookmark = bookmark
                                editLabel = bookmark.label
                            }) {
                                Image(systemName: "pencil")
                                    .font(.caption)
                                    .foregroundColor(theme.secondaryText)
                                    .padding(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                audioManager.removeBookmark(bookmark)
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .background(theme.pageBackground.ignoresSafeArea())
        .presentationDetents([.medium, .large])
        .alert("编辑书签名", isPresented: Binding(
            get: { editingBookmark != nil },
            set: { if !$0 { editingBookmark = nil } }
        )) {
            TextField("书签名", text: $editLabel)
            Button("取消", role: .cancel) { editingBookmark = nil }
            Button("保存") {
                if let bm = editingBookmark {
                    audioManager.renameBookmark(bm, to: editLabel)
                }
                editingBookmark = nil
            }
        } message: {
            Text("为书签输入一个便于记忆的名称")
        }
    }

    private var ambientSoundSheet: some View {
        NavigationStack {
            List {
                Section {
                    Toggle(isOn: $ambientManager.isAmbientEnabled) {
                        HStack(spacing: 10) {
                            Image(systemName: "speaker.wave.2.fill")
                                .foregroundColor(theme.accentRed)
                            Text("背景雅音")
                                .foregroundColor(theme.primaryText)
                        }
                    }
                    .tint(theme.accentRed)
                    .onChange(of: ambientManager.isAmbientEnabled) { _, enabled in
                        if enabled {
                            ambientManager.startEngine()
                        } else {
                            ambientManager.stopAll()
                        }
                    }

                    if ambientManager.isAmbientEnabled {
                        Text("轻声叠加雨声、风声、溪流，沉浸听书")
                            .font(.caption)
                            .foregroundColor(theme.tertiaryText)
                    }
                }

                if ambientManager.isAmbientEnabled {
                    Section("环境音") {
                        ForEach(AmbientSoundManager.SoundType.allCases, id: \.self) { type in
                            VStack(spacing: 8) {
                                HStack {
                                    Image(systemName: type.icon)
                                        .foregroundColor(type == .rain ? .blue : type == .wind ? .teal : type == .stream ? .cyan : type == .qinyun2 ? .indigo : .purple)
                                        .frame(width: 24)
                                    Text(type.rawValue)
                                        .foregroundColor(theme.primaryText)
                                    Spacer()
                                    Toggle("", isOn: Binding(
                                        get: { ambientManager.activeSounds.contains(type) },
                                        set: { _ in ambientManager.toggleSound(type) }
                                    ))
                                    .tint(theme.accentRed)
                                }

                                if ambientManager.activeSounds.contains(type) {
                                    HStack {
                                        Image(systemName: "speaker.fill")
                                            .font(.caption2)
                                            .foregroundColor(theme.tertiaryText)
                                        Slider(
                                            value: Binding(
                                                get: { ambientManager.volumes[type] ?? type.defaultVolume },
                                                set: { ambientManager.setVolume($0, for: type) }
                                            ),
                                            in: 0.0...0.6
                                        )
                                        .tint(type == .rain ? .blue : type == .wind ? .teal : type == .stream ? .cyan : type == .qinyun2 ? .indigo : .purple)
                                        Image(systemName: "speaker.wave.3.fill")
                                            .font(.caption2)
                                            .foregroundColor(theme.tertiaryText)
                                    }
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
            }
            .navigationTitle("背景雅音")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        showAmbientSounds = false
                    }
                    .foregroundColor(theme.accentRed)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Bookmark Model

struct Bookmark: Codable, Identifiable, Equatable {
    let id: UUID
    let time: TimeInterval
    var label: String
    let createdAt: Date

    init(time: TimeInterval) {
        self.id = UUID()
        self.time = time
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        self.label = String(format: "%d:%02d", minutes, seconds)
        self.createdAt = Date()
    }
}

// MARK: - Play Mode

enum PlayMode: CaseIterable {
    case single
    case loop
    case sequential

    var label: String {
        switch self {
        case .single: return "单回"
        case .loop: return "循环"
        case .sequential: return "连播"
        }
    }

    var iconName: String {
        switch self {
        case .single: return "arrow.right.to.line"
        case .loop: return "repeat.1"
        case .sequential: return "forward.end.fill"
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
    private var progressSaveTimer: Timer?
    private var wasPlayingBeforeInterruption = false
    private var healthCheckTimer: Timer?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var backgroundTaskRefreshTimer: Timer?
    private var currentTitle: String = ""
    private var currentFileName: String = ""
    private var timeControlObservation: NSKeyValueObservation?
    private var playerItemStatusObservation: NSKeyValueObservation?
    /// Timestamp of last successful background-task renewal (ticks every 2 s)
    private var healthCheckTick: Int = 0

    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var progress: Float = 0
    @Published var playMode: PlayMode = .single
    @Published var sleepTimerRemaining: TimeInterval = 0
    @Published var sleepTimerActive: Bool = false
    var sleepTimerTotal: TimeInterval = 0

    // Playlist & sequential playback
    var playlist: [Chapter] = []
    var currentPlaylistIndex: Int = -1
    @Published var currentPlayingChapter: Chapter?

    // Bookmarks
    @Published var bookmarks: [Bookmark] = []
    private var currentChapterNumber: Int = 0

    // MARK: - Bookmark Management

    private func bookmarksKey(for chapterNumber: Int) -> String {
        "bookmarks_\(chapterNumber)"
    }

    func loadBookmarks(for chapterNumber: Int) {
        currentChapterNumber = chapterNumber
        let key = bookmarksKey(for: chapterNumber)
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([Bookmark].self, from: data) else {
            bookmarks = []
            return
        }
        bookmarks = decoded.sorted { $0.time < $1.time }
    }

    func addBookmark() {
        guard currentTime > 1 else { return }
        let bookmark = Bookmark(time: currentTime)
        // Avoid duplicates within 3 seconds
        if bookmarks.contains(where: { abs($0.time - bookmark.time) < 3 }) { return }
        bookmarks.append(bookmark)
        bookmarks.sort { $0.time < $1.time }
        saveBookmarks()
    }

    func renameBookmark(_ bookmark: Bookmark, to newLabel: String) {
        guard let index = bookmarks.firstIndex(where: { $0.id == bookmark.id }),
              !newLabel.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        bookmarks[index].label = newLabel.trimmingCharacters(in: .whitespaces)
        saveBookmarks()
    }

    func removeBookmark(_ bookmark: Bookmark) {
        bookmarks.removeAll { $0.id == bookmark.id }
        saveBookmarks()
    }

    func seekToBookmark(_ bookmark: Bookmark) {
        let time = CMTime(seconds: bookmark.time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.seek(to: time)
        currentTime = bookmark.time
        progress = duration > 0 ? Float(bookmark.time / duration) : 0
        updateNowPlayingInfo()
    }

    private func saveBookmarks() {
        let key = bookmarksKey(for: currentChapterNumber)
        if let data = try? JSONEncoder().encode(bookmarks) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    // MARK: - Init

    private override init() {
        player = AVPlayer()
        player.automaticallyWaitsToMinimizeStalling = false
        player.allowsExternalPlayback = false
        player.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
        super.init()
        configureAudioSession()
        setupInterruptionNotification()
        setupRemoteCommandCenter()
        setupTimeControlObserver()
        setupRouteChangeNotification()
    }

    deinit {
        stopHealthCheck()
        stopBackgroundTaskRefresh()
        saveProgress(position: currentTime)
        stopProgressSaving()
        removeTimeObserver()
        timeControlObservation?.invalidate()
        playerItemStatusObservation?.invalidate()
        player.pause()
        sleepTimer?.invalidate()
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .spokenAudio,
                options: [.allowBluetoothA2DP, .mixWithOthers, .allowAirPlay])
            try session.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }

        UIApplication.shared.beginReceivingRemoteControlEvents()
    }

    func ensureAudioSessionActive() {
        let session = AVAudioSession.sharedInstance()
        // Re‑apply category in case system changed it (e.g. phone call ended)
        do {
            try session.setCategory(.playback, mode: .spokenAudio,
                options: [.allowBluetoothA2DP, .mixWithOthers, .allowAirPlay])
        } catch {
            print("AudioManager: setCategory failed: \(error)")
        }
        do {
            try session.setActive(true)
        } catch {
            print("AudioManager: setActive failed: \(error)")
        }
    }

    private func setupInterruptionNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioSessionInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )

        // Proactively begin background task before app resigns active (screen lock starts)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )

        // Ensure audio session stays active when app enters background
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    @objc private func handleAppWillResignActive() {
        guard isPlaying, player.currentItem != nil else { return }
        ensureAudioSessionActive()
        // Prime the audio pipeline: a brief play/pause cycle ensures
        // the system knows audio is active before the screen locks.
        // Request background execution time to prevent iOS from suspending
        // the app during screen lock transition.
        if backgroundTask == .invalid {
            backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
                self?.endBackgroundTask()
            }
        }
        // Kickstart background-task refresh loop
        startBackgroundTaskRefresh()
    }

    @objc private func handleAudioSessionInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        switch type {
        case .began:
            wasPlayingBeforeInterruption = isPlaying
            pause()
        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) && wasPlayingBeforeInterruption {
                do {
                    try AVAudioSession.sharedInstance().setActive(true)
                    play()
                } catch {
                    print("Failed to reactivate audio session: \(error)")
                }
            }
            wasPlayingBeforeInterruption = false
        @unknown default:
            break
        }
    }

    @objc private func handleAppDidEnterBackground() {
        guard isPlaying, player.currentItem != nil else { return }
        ensureAudioSessionActive()
        // Ensure background task is active to keep the audio pipeline alive
        endBackgroundTask()
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        startBackgroundTaskRefresh()

        // Force the player to keep running — with retry if it doesn't
        // take effect immediately (can happen during screen-lock transition)
        if player.timeControlStatus != .playing {
            player.play()
        }
        // Double-check after a short delay (screen-lock transition may
        // briefly suspend the media services)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self, self.isPlaying else { return }
            if self.player.timeControlStatus != .playing {
                self.ensureAudioSessionActive()
                self.player.play()
            }
        }
        updateNowPlayingInfo()
    }

    @objc private func handleAppWillEnterForeground() {
        ensureAudioSessionActive()
        endBackgroundTask()
        stopBackgroundTaskRefresh()
    }

    private func endBackgroundTask() {
        guard backgroundTask != .invalid else { return }
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }

    /// Proactively refresh the background task before it expires (~25s limit on iOS).
    /// Without this, iOS suspends the app ≈30s after screen lock, killing the health timer.
    private func startBackgroundTaskRefresh() {
        stopBackgroundTaskRefresh()
        backgroundTaskRefreshTimer = Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { [weak self] _ in
            guard let self = self, self.isPlaying else { return }
            let oldTask = self.backgroundTask
            self.backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
                self?.endBackgroundTask()
            }
            if oldTask != .invalid {
                UIApplication.shared.endBackgroundTask(oldTask)
            }
        }
        if let timer = backgroundTaskRefreshTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    private func stopBackgroundTaskRefresh() {
        backgroundTaskRefreshTimer?.invalidate()
        backgroundTaskRefreshTimer = nil
    }

    // MARK: - KVO Observers

    /// Monitor AVPlayer.timeControlStatus — if iOS pauses the player (e.g.
    /// buffer underrun during screen lock), automatically restart it.
    private func setupTimeControlObserver() {
        timeControlObservation = player.observe(\.timeControlStatus, options: [.new]) { [weak self] player, _ in
            guard let self = self, self.isPlaying, self.player.currentItem != nil else { return }
            if player.timeControlStatus == .paused {
                print("AudioManager: timeControlStatus → paused, auto-recovering")
                DispatchQueue.main.async {
                    self.ensureAudioSessionActive()
                    player.play()
                }
            }
        }
    }

    /// Detect audio route changes (e.g. Bluetooth connect/disconnect, route to
    /// receiver on lock) and re‑activate the session so playback isn't lost.
    private func setupRouteChangeNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
    }

    @objc private func handleRouteChange(_ notification: Notification) {
        guard isPlaying, player.currentItem != nil else { return }
        guard let reasonValue = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else { return }

        // Only react to route changes that could disrupt playback
        switch reason {
        case .oldDeviceUnavailable, .categoryChange, .override:
            print("AudioManager: route changed (\(reason.rawValue)), re-priming")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self, self.isPlaying else { return }
                self.ensureAudioSessionActive()
                if self.player.timeControlStatus != .playing {
                    self.player.play()
                }
            }
        default:
            break
        }
    }

    // MARK: - Playlist Management

    func configurePlaylist(_ chapters: [Chapter], startIndex: Int = 0) {
        playlist = chapters
        currentPlaylistIndex = startIndex
        if startIndex < chapters.count {
            currentPlayingChapter = chapters[startIndex]
        }
    }

    var hasNextChapter: Bool {
        guard playMode == .sequential, !playlist.isEmpty else { return false }
        return currentPlaylistIndex + 1 < playlist.count
    }

    func advanceToNextChapter() {
        guard hasNextChapter else {
            // End of playlist
            player.seek(to: .zero)
            isPlaying = false
            currentTime = 0
            progress = 0
            updateNowPlayingInfo()
            return
        }
        currentPlaylistIndex += 1
        let next = playlist[currentPlaylistIndex]
        currentPlayingChapter = next
        saveProgress(position: 0)
        loadAudio(for: next.audioFileName, title: next.title, chapterNumber: next.number)
        play()
    }

    // MARK: - Progress Persistence

    private func progressKey(for fileName: String) -> String {
        "progress_\(fileName)"
    }

    func savedProgress(for fileName: String) -> TimeInterval? {
        let key = progressKey(for: fileName)
        let value = UserDefaults.standard.double(forKey: key)
        return value > 0 ? value : nil
    }

    private func saveProgress(position: TimeInterval) {
        guard !currentFileName.isEmpty, duration > 0 else { return }
        let key = progressKey(for: currentFileName)
        let proportion = min(position / duration, 1.0)
        if position > 5 {
            UserDefaults.standard.set(proportion, forKey: key)
            UserDefaults.standard.synchronize()
        } else {
            UserDefaults.standard.removeObject(forKey: key)
        }
        // Notify ContentView to refresh progress display
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .progressUpdated, object: nil)
        }
    }

    private func startProgressSaving() {
        progressSaveTimer?.invalidate()
        progressSaveTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.saveProgress(position: self?.currentTime ?? 0)
            self?.onProgressTick()
        }
        // Stats: record every 30s (every 6th tick)
        statsTickCounter = 0
    }

    private var statsTickCounter: Int = 0
    private func stopProgressSaving() {
        progressSaveTimer?.invalidate()
        progressSaveTimer = nil
    }

    /// Called every 5 seconds during playback, records stats every 30s
    func onProgressTick() {
        statsTickCounter += 1
        if statsTickCounter % 6 == 0 {
            ListeningStatsManager.shared.recordTick()
        }
    }

    // MARK: - Audio Loading

    func loadAudio(for fileName: String, title: String = "", chapterNumber: Int = 0) {
        // Prefer downloaded cache, fall back to bundle
        let url: URL
        if let cached = AudioDownloadManager.shared.playableURL(for: fileName) {
            url = cached
        } else {
            print("Audio file not found: \(fileName)")
            return
        }

        // Save progress of current chapter before switching
        saveProgress(position: currentTime)
        stopProgressSaving()

        // Load bookmarks for this chapter
        if chapterNumber > 0 {
            loadBookmarks(for: chapterNumber)
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
        currentFileName = fileName
        currentTime = 0
        duration = 0
        progress = 0
        isPlaying = false

        let asset = AVURLAsset(url: url)
        playerItem = AVPlayerItem(asset: asset)
        // Large forward buffer: prevents audio gaps that can cause iOS to
        // tear down the audio pipeline while the screen is locked.
        playerItem?.preferredForwardBufferDuration = 120
        player.replaceCurrentItem(with: playerItem)

        // Restore saved progress flag (stored as proportion 0.0-1.0)
        let savedProportion = savedProgress(for: fileName)

        // Observe duration (iOS 16+ async API)
        Task { [weak self] in
            guard let self = self, let item = self.playerItem else { return }
            do {
                let duration = try await item.asset.load(.duration)
                let seconds = CMTimeGetSeconds(duration)
                guard seconds.isFinite && seconds > 0 else { return }
                await MainActor.run {
                    self.duration = seconds
                    self.updateNowPlayingInfo()
                    // Now that duration is known, restore saved progress
                    if let proportion = savedProportion, proportion > 0, proportion < 1.0 {
                        let seekSeconds = proportion * seconds
                        let seekTime = CMTime(seconds: seekSeconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                        self.player.seek(to: seekTime)
                        self.currentTime = seekSeconds
                        self.progress = Float(proportion)
                    }
                }
            } catch {
                print("Failed to load duration: \(error)")
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
        stopHealthCheck()
        DispatchQueue.main.async {
            // Save progress as 100% completed
            self.saveProgress(position: self.duration)
            self.stopProgressSaving()

            switch self.playMode {
            case .loop:
                self.player.seek(to: .zero)
                self.currentTime = 0
                self.progress = 0
                self.player.play()
                self.isPlaying = true
                self.startProgressSaving()
                self.updateNowPlayingInfo()

            case .sequential:
                self.advanceToNextChapter()

            case .single:
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
        wasPlayingBeforeInterruption = false
        player.playImmediately(atRate: 1.0)
        isPlaying = true
        startProgressSaving()
        updateNowPlayingInfo()
        startHealthCheck()
    }

    func pause() {
        // Set isPlaying = false FIRST so the KVO observer and health-check
        // timer won't auto-restart playback when they see timeControlStatus
        // change to .paused.
        wasPlayingBeforeInterruption = false
        isPlaying = false
        stopHealthCheck()
        stopBackgroundTaskRefresh()
        endBackgroundTask()
        player.pause()
        saveProgress(position: currentTime)
        stopProgressSaving()
        updateNowPlayingInfo()
    }

    /// Background health‑check: runs every 2 s. Verifies the player is truly
    /// producing audio, re‑activates the session if needed, and renews the
    /// background task every 10 ticks (20 s) to prevent iOS suspension.
    private func startHealthCheck() {
        stopHealthCheck()
        healthCheckTick = 0
        healthCheckTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isPlaying, self.player.currentItem != nil else { return }
            self.healthCheckTick += 1

            // Renew background task every 10 ticks (20 s) to stay alive
            if self.healthCheckTick % 10 == 0 {
                let oldTask = self.backgroundTask
                self.backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
                    self?.endBackgroundTask()
                }
                if oldTask != .invalid {
                    UIApplication.shared.endBackgroundTask(oldTask)
                }
            }

            // Check the player's actual status — AVPlayer can silently stop
            // in background when the audio pipeline is torn down by iOS
            let status = self.player.timeControlStatus
            if status != .playing {
                print("AudioManager: health-check — status=\(status.rawValue), recovering")
                self.ensureAudioSessionActive()
                // Re-create the player's playback intention
                self.player.playImmediately(atRate: 1.0)
                // Verify it took effect
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    guard let self = self, self.isPlaying else { return }
                    if self.player.timeControlStatus != .playing {
                        self.player.play()
                    }
                }
                self.updateNowPlayingInfo()
            } else if self.player.rate == 0 {
                // rate can be 0 even when timeControlStatus == .playing
                // during a buffer stall — force resume
                print("AudioManager: health-check — rate=0, forcing play")
                self.player.playImmediately(atRate: 1.0)
            }
        }
        // Allow the timer to fire while scrolling, in background, etc.
        if let timer = healthCheckTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    private func stopHealthCheck() {
        healthCheckTimer?.invalidate()
        healthCheckTimer = nil
        healthCheckTick = 0
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

extension Notification.Name {
    static let progressUpdated = Notification.Name("progressUpdated")
}