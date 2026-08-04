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

        var icon: String {
            switch self {
            case .rain: return "cloud.rain.fill"
            case .wind: return "wind"
            case .stream: return "water.waves"
            }
        }

        var color: String {
            switch self {
            case .rain: return "blue"
            case .wind: return "teal"
            case .stream: return "cyan"
            }
        }

        var defaultVolume: Float { 0.25 }
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
        .stream: "ambient_vol_stream"
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

    private func generateBuffer(for type: SoundType, format: AVAudioFormat) -> AVAudioPCMBuffer {
        let frameCount = AVAudioFrameCount(bufferDuration * sampleRate)
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
        var burstDecay: Float = 0.999

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
}
