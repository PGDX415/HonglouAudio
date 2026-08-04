//
//  AmbientSoundManager.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/8/4.
//

import AVFoundation
import Combine

final class AmbientSoundManager: ObservableObject {
    static let shared = AmbientSoundManager()

    enum SoundType: String, CaseIterable, Codable {
        case rain = "雨声"
        case wind = "风声"
        case stream = "溪流"
        case qinyun = "琴韵"

        var icon: String {
            switch self {
            case .rain: return "cloud.rain.fill"
            case .wind: return "wind"
            case .stream: return "water.waves"
            case .qinyun: return "music.quarternote.3"
            }
        }

        var color: String {
            switch self {
            case .rain: return "blue"
            case .wind: return "teal"
            case .stream: return "cyan"
            case .qinyun: return "purple"
            }
        }

        var defaultVolume: Float {
            switch self {
            case .qinyun: return 0.20
            default: return 0.25
            }
        }

        var bufferSeconds: TimeInterval {
            switch self {
            case .qinyun: return 20.0
            default: return 10.0
            }
        }
    }

    @Published var isAmbientEnabled = false
    @Published var activeSounds: Set<SoundType> = []
    @Published var volumes: [SoundType: Float] = [:]

    private let engine = AVAudioEngine()
    private var playerNodes: [SoundType: AVAudioPlayerNode] = [:]
    private var isEngineStarted = false
    private let sampleRate: Double = 44100
    private let bufferDuration: TimeInterval = 10.0

    private static let volumeKeys: [SoundType: String] = [
        .rain: "ambient_vol_rain",
        .wind: "ambient_vol_wind",
        .stream: "ambient_vol_stream",
        .qinyun: "ambient_vol_qinyun"
    ]

    private init() {
        for type in SoundType.allCases {
            let saved = UserDefaults.standard.float(forKey: Self.volumeKeys[type]!)
            volumes[type] = saved > 0 ? saved : type.defaultVolume
        }
        setupEngine()
    }

    // MARK: - Engine Setup

    private func setupEngine() {
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!

        for type in SoundType.allCases {
            let playerNode = AVAudioPlayerNode()
            engine.attach(playerNode)
            engine.connect(playerNode, to: engine.mainMixerNode, format: format)
            playerNodes[type] = playerNode
        }

        engine.mainMixerNode.volume = 0.8
    }

    // MARK: - Public Controls

    func toggleSound(_ type: SoundType) {
        if activeSounds.contains(type) {
            stopSound(type)
        } else {
            startSound(type)
        }
    }

    func setVolume(_ volume: Float, for type: SoundType) {
        volumes[type] = volume
        UserDefaults.standard.set(volume, forKey: Self.volumeKeys[type]!)
        if activeSounds.contains(type) {
            playerNodes[type]?.volume = volume
        }
    }

    func toggleMaster() {
        isAmbientEnabled.toggle()
        if isAmbientEnabled {
            startEngine()
        } else {
            stopAll()
        }
    }

    // MARK: - Sound Control

    private func startSound(_ type: SoundType) {
        guard isAmbientEnabled else { return }
        activeSounds.insert(type)

        guard let playerNode = playerNodes[type] else { return }

        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let buffer = generateBuffer(for: type, format: format)
        playerNode.volume = volumes[type] ?? type.defaultVolume

        if !playerNode.isPlaying {
            playerNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
            if !engine.isRunning {
                startEngine()
            }
            playerNode.play()
        }
    }

    private func stopSound(_ type: SoundType) {
        activeSounds.remove(type)
        playerNodes[type]?.stop()

        if activeSounds.isEmpty && isAmbientEnabled {
            // Keep engine running but all sounds stopped
        }

        if activeSounds.isEmpty && !isAmbientEnabled {
            stopEngine()
        }
    }

    func stopAll() {
        for type in SoundType.allCases {
            playerNodes[type]?.stop()
        }
        activeSounds.removeAll()
        stopEngine()
    }

    func startEngine() {
        guard !engine.isRunning else { return }
        do {
            try engine.start()
            isEngineStarted = true
        } catch {
            print("AmbientSoundManager: engine start failed: \(error)")
        }
    }

    func stopEngine() {
        guard engine.isRunning else { return }
        engine.stop()
        isEngineStarted = false
    }

    // MARK: - Buffer Generation

    /// Try loading a bundled custom audio file (e.g. AI‑generated music).
    /// Looks for `ambient_qinyun.mp3` in the main bundle.
    /// Falls back to synthesis if the file is not found.
    private func loadBundledMusic(named fileName: String) -> AVAudioPCMBuffer? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: nil) else {
            return nil
        }
        guard let file = try? AVAudioFile(forReading: url) else {
            print("AmbientSoundManager: could not open \(fileName)")
            return nil
        }

        let engineFormat = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        guard let converter = AVAudioConverter(from: file.processingFormat, to: engineFormat) else {
            return nil
        }

        // Read the entire file
        let fileFrames = AVAudioFrameCount(file.length)
        guard let fileBuffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: fileFrames) else {
            return nil
        }
        do {
            try file.read(into: fileBuffer)
        } catch {
            print("AmbientSoundManager: read error \(fileName): \(error)")
            return nil
        }

        // Convert to engine format
        let outFrames = AVAudioFrameCount(Double(fileFrames) * sampleRate / file.processingFormat.sampleRate)
        guard let outBuffer = AVAudioPCMBuffer(pcmFormat: engineFormat, frameCapacity: outFrames) else {
            return nil
        }

        var error: NSError?
        let inputBlock: AVAudioConverterInputBlock = { _, outStatus in
            outStatus.pointee = .haveData
            return fileBuffer
        }
        converter.convert(to: outBuffer, error: &error, withInputFrom: inputBlock)

        if let error = error {
            print("AmbientSoundManager: convert error \(fileName): \(error)")
            return nil
        }

        print("AmbientSoundManager: loaded custom music \(fileName)")
        return outBuffer
    }

    private func generateBuffer(for type: SoundType, format: AVAudioFormat) -> AVAudioPCMBuffer {
        // For qinyun, try bundled audio file first
        if type == .qinyun, let bundled = loadBundledMusic(named: "ambient_qinyun.mp3") {
            return bundled
        }

        let duration = type.bufferSeconds
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            fatalError("Could not create PCM buffer")
        }
        buffer.frameLength = frameCount

        guard let channelData = buffer.floatChannelData?[0] else { return buffer }

        switch type {
        case .rain:
            generateRainNoise(into: channelData, count: Int(frameCount))
        case .wind:
            generateWindNoise(into: channelData, count: Int(frameCount))
        case .stream:
            generateStreamNoise(into: channelData, count: Int(frameCount))
        case .qinyun:
            generateQinMelody(into: channelData, count: Int(frameCount))
        }

        return buffer
    }

    // MARK: - Rain Sound Generator

    /// Rain: filtered white noise with random intensity bursts
    private func generateRainNoise(into data: UnsafeMutablePointer<Float>, count: Int) {
        var prevSample: Float = 0
        let alpha: Float = 0.15  // low-pass coefficient (0 = no filtering, 1 = max)
        let baseGain: Float = 0.2
        let burstChance: Float = 0.002
        var burstGain: Float = 1.0
        let burstDecay: Float = 0.999

        for i in 0..<count {
            let rawNoise = Float.random(in: -1...1)

            // Simple low-pass filter: y[n] = α * x[n] + (1-α) * y[n-1]
            let filtered = alpha * rawNoise + (1 - alpha) * prevSample
            prevSample = filtered

            // Random rain bursts
            if Float.random(in: 0...1) < burstChance {
                burstGain = Float.random(in: 2.0...4.5)
            }
            burstGain = 1.0 + (burstGain - 1.0) * burstDecay

            data[i] = filtered * baseGain * burstGain
        }
    }

    // MARK: - Wind Sound Generator

    /// Wind: very low-frequency filtered noise with slow amplitude modulation
    private func generateWindNoise(into data: UnsafeMutablePointer<Float>, count: Int) {
        var prevLow: Float = 0
        var prevMid: Float = 0
        let lowAlpha: Float = 0.02
        let midAlpha: Float = 0.03
        let modFreq: Float = 0.08  // very slow LFO for gusts
        let baseGain: Float = 0.25

        for i in 0..<count {
            let rawNoise = Float.random(in: -1...1)

            // Very heavy low-pass for the deep wind rumble
            let lowPass = lowAlpha * rawNoise + (1 - lowAlpha) * prevLow
            prevLow = lowPass

            // Slightly less filtered mid component
            let midPass = midAlpha * rawNoise + (1 - midAlpha) * prevMid
            prevMid = midPass

            // Slow sinusoidal modulation for wind gusts
            let mod = 0.5 + 0.5 * sin(Float(i) * modFreq * 2 * .pi / Float(count) * 100)

            let combined = (lowPass * 0.7 + midPass * 0.3)
            data[i] = combined * baseGain * (0.4 + 0.6 * mod)
        }
    }

    // MARK: - Stream Sound Generator

    /// Stream: band-pass-like noise with gentle high-frequency sparkle
    private func generateStreamNoise(into data: UnsafeMutablePointer<Float>, count: Int) {
        var prev1: Float = 0
        var prev2: Float = 0
        let alpha: Float = 0.4
        let baseGain: Float = 0.18
        let sparkleGain: Float = 0.08

        for i in 0..<count {
            let rawNoise = Float.random(in: -1...1)

            // Band-pass approximation: difference between two low-pass filters
            let lp1 = alpha * rawNoise + (1 - alpha) * prev1
            prev1 = lp1
            let lp2 = (alpha * 0.3) * rawNoise + (1 - alpha * 0.3) * prev2
            prev2 = lp2
            let bandPass = lp1 - lp2

            // Add high-frequency sparkle (for water ripples)
            let sparkle = rawNoise * 0.3
            let hasSparkle = Float.random(in: 0...1) < 0.15

            data[i] = bandPass * baseGain + (hasSparkle ? sparkle * sparkleGain : 0)
        }
    }

    // MARK: - Qin Melody Generator

    /// Sparse pentatonic melody evoking guqin atmosphere.
    /// Uses 宫商角徵羽 scale with gentle harmonics and long decays.
    private func generateQinMelody(into data: UnsafeMutablePointer<Float>, count: Int) {
        // Chinese pentatonic scale frequencies (low octave, meditative)
        let scale: [Float] = [
            130.81,  // C3 宫
            146.83,  // D3 商
            164.81,  // E3 角
            196.00,  // G3 徵
            220.00,  // A3 羽
            261.63,  // C4 宫
            293.66,  // D4 商
            329.63,  // E4 角
            392.00,  // G4 徵
            440.00,  // A4 羽
        ]

        let baseGain: Float = 0.09

        // Melody pattern: (scale index, duration in samples)
        // A 20-second meditative sequence
        let noteDuration: Float = 2.2  // seconds per note
        let samplesPerNote = Int(noteDuration * Float(sampleRate))
        let overlap: Int = Int(0.5 * Float(sampleRate))  // notes overlap by 0.5s

        // Gentle pentatonic sequence in the style of guqin improvisation
        let melody: [(Int, Float)] = [
            (5, 1.0),   // C4
            (7, 0.9),   // E4
            (9, 0.85),  // A4
            (7, 0.8),   // E4
            (4, 0.9),   // A3
            (0, 0.85),  // C3
            (2, 0.9),   // E3
            (4, 0.8),   // A3
            (5, 1.0),   // C4
        ]

        // Track the envelope for smooth overlapping notes
        var envelopeSum: Float = 0
        let envelopeMax: Float = 1.5  // soft clip for overlap

        for i in 0..<count {
            var sample: Float = 0

            for (noteIdx, (scaleIdx, ampMod)) in melody.enumerated() {
                let noteStart = noteIdx * samplesPerNote - noteIdx * overlap / melody.count
                let noteEnd = noteStart + samplesPerNote + overlap * 2
                guard i >= noteStart, i < noteEnd else { continue }

                let freq = scale[scaleIdx]

                // Position within note (0 = start, 1 = end of sustain)
                let posInNote = Float(i - noteStart) / Float(samplesPerNote)

                // ADSR-like envelope for guqin pluck character
                let attack: Float = 0.04   // quick attack (pluck)
                let decay: Float = 0.15    // slight decay after pluck
                let sustain: Float = 0.6   // long gentle sustain
                var envelope: Float
                if posInNote < attack {
                    envelope = posInNote / attack
                } else if posInNote < attack + decay {
                    let t = (posInNote - attack) / decay
                    envelope = 1.0 - t * 0.3  // decay to 0.7
                } else if posInNote < sustain {
                    envelope = 0.7
                } else {
                    // Long release tail
                    let t = (posInNote - sustain) / (1.0 - sustain)
                    envelope = 0.7 * (1.0 - t) * (1.0 - t)
                }

                // Phase accumulator for sine wave
                let t = Float(i - noteStart) / Float(sampleRate)

                // Fundamental + subtle harmonics (like guqin overtones)
                let fundamental = sin(2 * .pi * freq * t)
                let harmonic2 = 0.25 * sin(2 * .pi * freq * 2.0 * t + 0.3)
                let harmonic3 = 0.12 * sin(2 * .pi * freq * 3.0 * t + 0.7)
                let harmonic4 = 0.06 * sin(2 * .pi * freq * 4.0 * t + 1.1)

                // Gentle vibrato on longer notes
                let vibratoDepth: Float = posInNote > 0.1 ? 0.003 : 0
                let vibrato = 1.0 + vibratoDepth * sin(2 * .pi * 4.5 * t)

                let noteSample = (fundamental + harmonic2 + harmonic3 + harmonic4)
                    * envelope * ampMod * vibrato

                sample += noteSample
            }

            // Soft clip to prevent harsh peaks during note overlap
            sample = sample * baseGain
            if sample > envelopeMax { sample = envelopeMax }
            if sample < -envelopeMax { sample = -envelopeMax }

            data[i] = sample
        }
    }
}
