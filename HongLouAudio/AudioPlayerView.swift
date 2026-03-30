import SwiftUI
import AVFoundation
import Combine

struct AudioPlayerView: View {
    @StateObject private var audioManager = AudioManager()
    let chapter: Chapter
    
    var body: some View {
        ZStack {
            // Classical Chinese background - antique paper texture
            Color(red: 0.98, green: 0.96, blue: 0.92)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Chapter title
                Text(chapter.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.2, green: 0.1, blue: 0.1)) // Deep ink color
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Summary
                Text(chapter.summary)
                    .font(.body)
                    .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.2)) // Warm brown text
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                // Time labels
                HStack {
                    Text(formatTime(audioManager.currentTime))
                        .font(.caption)
                        .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.2))
                    
                    Spacer()
                    
                    Text(formatTime(audioManager.duration))
                        .font(.caption)
                        .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.2))
                }
                .padding(.horizontal)
                
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
                .tint(Color(red: 0.6, green: 0.2, blue: 0.2)) // Classical red tint
                .padding(.horizontal)
                
                // Control buttons
                HStack(spacing: 40) {
                    // Rewind 10 seconds
                    Button(action: {
                        audioManager.rewind(seconds: 10)
                    }) {
                        Image(systemName: "gobackward.10")
                            .font(.title2)
                            .foregroundColor(Color(red: 0.2, green: 0.1, blue: 0.1))
                            .padding(15)
                            .background(Color(red: 0.92, green: 0.88, blue: 0.80)) // Light antique background
                            .clipShape(Circle())
                    }
                    
                    // Play/Pause button
                    Button(action: {
                        audioManager.togglePlayPause(for: chapter.audioFileName)
                    }) {
                        Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding(20)
                            .background(
                                Circle()
                                    .fill(audioManager.isPlaying ? Color(red: 0.7, green: 0.3, blue: 0.3) : Color(red: 0.6, green: 0.2, blue: 0.2)) // Classical red variants
                                    .shadow(color: Color(red: 0.2, green: 0.1, blue: 0.1).opacity(0.3), radius: 5, x: 0, y: 3)
                            )
                    }
                    
                    // Forward 10 seconds
                    Button(action: {
                        audioManager.forward(seconds: 10)
                    }) {
                        Image(systemName: "goforward.10")
                            .font(.title2)
                            .foregroundColor(Color(red: 0.2, green: 0.1, blue: 0.1))
                            .padding(15)
                            .background(Color(red: 0.92, green: 0.88, blue: 0.80)) // Light antique background
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom)
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            audioManager.loadAudio(for: chapter.audioFileName)
        }
        .onDisappear {
            if audioManager.isPlaying {
                audioManager.pause()
            }
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

class AudioManager: NSObject, ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var progress: Float = 0
    
    func loadAudio(for fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: nil) else {
            print("Audio file not found: \(fileName)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            duration = audioPlayer?.duration ?? 0
            currentTime = audioPlayer?.currentTime ?? 0
            progress = duration > 0 ? Float(currentTime / duration) : 0
        } catch {
            print("Error loading audio: \(error)")
        }
    }
    
    func togglePlayPause(for fileName: String) {
        if audioPlayer == nil {
            loadAudio(for: fileName)
        }
        
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    func play() {
        audioPlayer?.play()
        isPlaying = true
        startTimer()
    }
    
    func pause() {
        audioPlayer?.pause()
        isPlaying = false
        stopTimer()
    }
    
    func rewind(seconds: TimeInterval) {
        var newTime = (audioPlayer?.currentTime ?? 0) - seconds
        if newTime < 0 {
            newTime = 0
        }
        audioPlayer?.currentTime = newTime
        currentTime = newTime
        progress = duration > 0 ? Float(newTime / duration) : 0
    }
    
    func forward(seconds: TimeInterval) {
        var newTime = (audioPlayer?.currentTime ?? 0) + seconds
        if newTime > (audioPlayer?.duration ?? 0) {
            newTime = audioPlayer?.duration ?? 0
        }
        audioPlayer?.currentTime = newTime
        currentTime = newTime
        progress = duration > 0 ? Float(newTime / duration) : 0
    }
    
    func seek(to progress: Float) {
        let newTime = TimeInterval(progress) * (audioPlayer?.duration ?? 0)
        audioPlayer?.currentTime = newTime
        currentTime = newTime
        self.progress = progress
        
        if isPlaying {
            audioPlayer?.play()
        }
    }
    
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            guard let player = self.audioPlayer else { return }
            self.currentTime = player.currentTime
            self.duration = player.duration
            self.progress = self.duration > 0 ? Float(self.currentTime / self.duration) : 0
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.currentTime = 0
            self.progress = 0
            self.stopTimer()
        }
    }
}