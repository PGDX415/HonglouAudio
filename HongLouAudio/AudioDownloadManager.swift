//
//  AudioDownloadManager.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/8/6.
//

import Foundation
import Combine

/// Manages downloading audio files from remote server to local cache.
/// Once downloaded, AudioManager loads from cache instead of bundle.
final class AudioDownloadManager: NSObject, ObservableObject {
    static let shared = AudioDownloadManager()

    // MARK: - Configuration

    /// Remote base URL for audio files. Set this to your CDN/server URL.
    /// Files are expected at: {baseURL}/{audioFileName}
    /// Example: "https://cdn.example.com/honglou/audio/"
    var remoteBaseURL: String {
        get { UserDefaults.standard.string(forKey: "audioRemoteBaseURL") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "audioRemoteBaseURL") }
    }

    // MARK: - Published State

    /// Download progress per audio file name (0.0...1.0)
    @Published var downloadProgress: [String: Double] = [:]

    /// Currently downloading file names
    @Published var activeDownloads: Set<String> = []

    /// Successfully downloaded file names
    @Published var downloadedFiles: Set<String> = []

    /// Download errors per file name
    @Published var downloadErrors: [String: String] = [:]

    // MARK: - Private

    private var tasks: [String: URLSessionDownloadTask] = [:]
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "com.honglouaudio.downloads")
        config.isDiscretionary = false
        config.sessionSendsLaunchEvents = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()

    private override init() {
        super.init()
        loadDownloadedFiles()
    }

    // MARK: - Local Cache Path

    /// Directory where downloaded audio files are stored
    var downloadDirectory: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dir = docs.appendingPathComponent("DownloadedAudio")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    /// Local file URL for a given audio file name (may not exist yet)
    func localURL(for fileName: String) -> URL {
        downloadDirectory.appendingPathComponent(fileName)
    }

    /// Check if a file has been downloaded
    func isDownloaded(_ fileName: String) -> Bool {
        FileManager.default.fileExists(atPath: localURL(for: fileName).path)
    }

    /// URL to use for playback: cached > bundle
    func playableURL(for fileName: String) -> URL? {
        let local = localURL(for: fileName)
        if FileManager.default.fileExists(atPath: local.path) {
            return local
        }
        return Bundle.main.url(forResource: fileName, withExtension: nil)
    }

    // MARK: - Download

    /// Start downloading a single audio file
    func download(fileName: String) {
        guard !isDownloaded(fileName) else { return }
        guard !activeDownloads.contains(fileName) else { return }
        guard !remoteBaseURL.isEmpty else {
            downloadErrors[fileName] = "未配置远程服务器地址"
            return
        }

        guard let url = URL(string: remoteBaseURL + fileName) else {
            downloadErrors[fileName] = "无效的下载地址"
            return
        }

        downloadErrors.removeValue(forKey: fileName)
        activeDownloads.insert(fileName)
        downloadProgress[fileName] = 0
        DownloadTracker.shared.beginDownload(fileName)

        let task = session.downloadTask(with: url)
        tasks[fileName] = task
        task.resume()
    }

    /// Download all chapters in a season
    func downloadSeason(_ season: Season, chapters: [Chapter]) {
        let files = chapters
            .filter { $0.season == season.id }
            .map { $0.audioFileName }
        for file in files {
            download(fileName: file)
        }
    }

    /// Cancel a download
    func cancel(fileName: String) {
        tasks[fileName]?.cancel()
        tasks.removeValue(forKey: fileName)
        activeDownloads.remove(fileName)
        downloadProgress.removeValue(forKey: fileName)
        DownloadTracker.shared.cancelDownload(fileName)
    }

    /// Cancel all downloads
    func cancelAll() {
        for (name, task) in tasks {
            task.cancel()
            DownloadTracker.shared.cancelDownload(name)
        }
        tasks.removeAll()
        activeDownloads.removeAll()
        downloadProgress.removeAll()
    }

    /// Delete a downloaded file
    func deleteFile(_ fileName: String) {
        let url = localURL(for: fileName)
        try? FileManager.default.removeItem(at: url)
        loadDownloadedFiles()
    }

    /// Delete all downloaded files in a season
    func deleteSeason(_ season: Season, chapters: [Chapter]) {
        for ch in chapters where ch.season == season.id {
            try? FileManager.default.removeItem(at: localURL(for: ch.audioFileName))
        }
        loadDownloadedFiles()
    }

    /// Total size of downloaded audio files
    var downloadedSize: Int64 {
        var total: Int64 = 0
        for file in downloadedFiles {
            let url = localURL(for: file)
            if let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
               let size = attrs[.size] as? Int64 {
                total += size
            }
        }
        return total
    }

    /// Number of downloaded files
    var downloadedCount: Int {
        downloadedFiles.count
    }

    // MARK: - Private Helpers

    private func loadDownloadedFiles() {
        let fm = FileManager.default
        let dir = downloadDirectory
        if let contents = try? fm.contentsOfDirectory(atPath: dir.path) {
            downloadedFiles = Set(contents.filter { $0.hasSuffix(".mp3") })
        }
    }
}

// MARK: - URLSessionDownloadDelegate

extension AudioDownloadManager: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // Find which file this task belongs to
        guard downloadTask.originalRequest?.url != nil else { return }
        guard let fileName = tasks.first(where: { $0.value == downloadTask })?.key else { return }

        let destination = localURL(for: fileName)
        try? FileManager.default.removeItem(at: destination) // Remove old if exists
        do {
            try FileManager.default.moveItem(at: location, to: destination)
            DispatchQueue.main.async { [weak self] in
                self?.activeDownloads.remove(fileName)
                self?.tasks.removeValue(forKey: fileName)
                self?.downloadProgress[fileName] = 1.0
                self?.loadDownloadedFiles()
                DownloadTracker.shared.completeDownload(fileName)
                // Notify that audio is ready
                NotificationCenter.default.post(name: .audioDownloadComplete, object: fileName)
            }
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.activeDownloads.remove(fileName)
                self?.tasks.removeValue(forKey: fileName)
                self?.downloadErrors[fileName] = "文件保存失败"
                DownloadTracker.shared.failDownload(fileName)
            }
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let fileName = tasks.first(where: { $0.value == downloadTask })?.key else { return }
        guard totalBytesExpectedToWrite > 0 else { return }
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        DispatchQueue.main.async { [weak self] in
            self?.downloadProgress[fileName] = progress
            DownloadTracker.shared.updateProgress(fileName, progress: progress)
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let fileName = tasks.first(where: { $0.value == task })?.key else { return }
        if let error = error {
            DispatchQueue.main.async { [weak self] in
                self?.activeDownloads.remove(fileName)
                self?.tasks.removeValue(forKey: fileName)
                self?.downloadErrors[fileName] = error.localizedDescription
                DownloadTracker.shared.failDownload(fileName)
            }
        }
    }
}

// MARK: - Download Tracker (for widgets / live activities)

final class DownloadTracker: ObservableObject {
    static let shared = DownloadTracker()

    @Published var activeDownloadCount: Int = 0
    @Published var overallProgress: Double = 0

    private var fileProgress: [String: Double] = [:]
    private var totalFiles: Int = 0
    private var completedFiles: Int = 0

    func beginDownload(_ fileName: String) {
        totalFiles += 1
        fileProgress[fileName] = 0
        updateCount()
    }

    func updateProgress(_ fileName: String, progress: Double) {
        fileProgress[fileName] = progress
        updateOverall()
    }

    func completeDownload(_ fileName: String) {
        completedFiles += 1
        fileProgress[fileName] = 1.0
        updateOverall()
        updateCount()
    }

    func cancelDownload(_ fileName: String) {
        fileProgress.removeValue(forKey: fileName)
        updateOverall()
        updateCount()
    }

    func failDownload(_ fileName: String) {
        fileProgress.removeValue(forKey: fileName)
        updateOverall()
        updateCount()
    }

    private func updateCount() {
        activeDownloadCount = fileProgress.count
    }

    private func updateOverall() {
        guard totalFiles > 0 else { overallProgress = 0; return }
        let sum = fileProgress.values.reduce(0, +)
        overallProgress = sum / Double(max(totalFiles, 1))
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let audioDownloadComplete = Notification.Name("audioDownloadComplete")
}
