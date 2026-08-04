//
//  MyAccountView.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/3/31.
//

import SwiftUI

struct MyAccountView: View {
    @State private var playbackSpeed: Float = 1.0
    @ObservedObject private var theme = ThemeManager.shared
    @ObservedObject private var statsManager = ListeningStatsManager.shared
    @State private var volume: Float = 0.8
    @AppStorage("textFontSize") private var textFontSize: Double = 18.0

    private let fontSizes: [(Double, String)] = [
        (15, "小"),
        (18, "中"),
        (21, "大"),
        (24, "超大")
    ]

    var body: some View {
        List {
                // Reading stats card
                Section {
                    HStack(spacing: 0) {
                        statItem(value: statsManager.formattedTotalTime, label: "收听时长")
                        Divider().frame(height: 36)
                        statItem(value: "\(statsManager.completedChapterCount)", label: "已听完回")
                        Divider().frame(height: 36)
                        statItem(value: "\(statsManager.currentStreak)", label: "连续天数")
                    }
                    .padding(.vertical, 4)
                }

                Section("账户信息") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "person.circle")
                                .font(.title)
                                .foregroundColor(theme.accentRed) // Classical red
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("红楼聆梦用户")
                                    .font(.headline)
                                    .foregroundColor(theme.primaryText)
                                
                                Text("guest@example.com")
                                    .font(.caption)
                                    .foregroundColor(theme.secondaryText)
                            }
                            .padding(.leading, 8)
                            
                            Spacer()
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section("音频设置") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("播放速度")
                                .foregroundColor(theme.primaryText)
                            Spacer()
                            Text("\(playbackSpeed, specifier: "%.1fx")")
                                .foregroundColor(theme.secondaryText)
                        }
                        
                        Slider(value: $playbackSpeed, in: 0.5...2.0, step: 0.1)
                            .accentColor(theme.accentRed)
                        
                        HStack {
                            Text("音量控制")
                                .foregroundColor(theme.primaryText)
                            Spacer()
                            Text("\(Int(volume * 100))%")
                                .foregroundColor(theme.secondaryText)
                        }
                        
                        Slider(value: $volume, in: 0.0...1.0, step: 0.05)
                            .accentColor(theme.accentRed)
                    }
                    .padding(.vertical, 4)
                }
                
                Section("正文设置") {
                    Picker("字体大小", selection: $textFontSize) {
                        ForEach(fontSizes, id: \.0) { size, label in
                            Text(label).tag(size)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.vertical, 4)
                }

                Section("红楼雅趣") {
                    NavigationLink(destination: PersonalityQuizView()) {
                        HStack {
                            Image(systemName: "theatermask.and.paintbrush.fill")
                                .foregroundColor(Color(red: 0.55, green: 0.4, blue: 0.65))
                            Text("我像红楼梦里的谁")
                                .foregroundColor(theme.primaryText)
                            Spacer()
                            Text("人格测试")
                                .font(.caption)
                                .foregroundColor(theme.tertiaryText)
                        }
                    }

                    NavigationLink(destination: FlowerLotView().navigationBarHidden(true)) {
                        HStack {
                            Image(systemName: "camera.macro")
                                .foregroundColor(Color(red: 0.8, green: 0.4, blue: 0.5))
                            Text("花名签")
                                .foregroundColor(theme.primaryText)
                            Spacer()
                            Text("寿怡红群芳开夜宴")
                                .font(.caption)
                                .foregroundColor(theme.tertiaryText)
                        }
                    }

                    NavigationLink(destination: FortuneView().navigationBarHidden(true)) {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.2))
                            Text("求签问卜")
                                .foregroundColor(theme.primaryText)
                            Spacer()
                            Text("太虚幻境")
                                .font(.caption)
                                .foregroundColor(theme.tertiaryText)
                        }
                    }

                    NavigationLink(destination: RecipeView()) {
                        HStack {
                            Image(systemName: "fork.knife")
                                .foregroundColor(theme.accentRed)
                            Text("红楼食谱")
                                .foregroundColor(theme.primaryText)
                            Spacer()
                            Text("\(RecipeStore.recipes.count)道")
                                .font(.caption)
                                .foregroundColor(theme.tertiaryText)
                        }
                    }

                    NavigationLink(destination: QuizView()) {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundColor(theme.accentRed)
                            Text("知识问答")
                                .foregroundColor(theme.primaryText)
                            Spacer()
                            Text("历史最佳：\(UserDefaults.standard.integer(forKey: "quiz_best_score"))/10")
                                .font(.caption)
                                .foregroundColor(theme.tertiaryText)
                        }
                    }
                }

                Section("显示设置") {
                    Toggle(isOn: $theme.isDarkMode) {
                        HStack {
                            Image(systemName: theme.isDarkMode ? "moon.fill" : "moon")
                                .foregroundColor(theme.accentRed)
                            Text("夜间模式")
                                .foregroundColor(theme.primaryText)
                        }
                    }
                    .tint(theme.accentRed)
                }

                Section("法律与隐私") {
                    NavigationLink(destination: LegalContentView(title: "隐私政策", content: privacyPolicyContent)) {
                        HStack {
                            Image(systemName: "lock.shield")
                                .foregroundColor(theme.accentRed)
                            Text("隐私政策")
                                .foregroundColor(theme.primaryText)
                            Spacer()
                        }
                    }
                    
                    NavigationLink(destination: LegalContentView(title: "使用协议", content: termsOfServiceContent)) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(theme.accentRed)
                            Text("使用协议")
                                .foregroundColor(theme.primaryText)
                            Spacer()
                        }
                    }
                }
                
                Section("其他") {
                    NavigationLink(destination: LegalContentView(title: "关于我们", content: aboutContent)) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(theme.accentRed)
                            Text("关于我们")
                                .foregroundColor(theme.primaryText)
                            Spacer()
                        }
                    }
                    
                    NavigationLink(destination: GlossaryBrowseView()) {
                        HStack {
                            Image(systemName: "character.book.closed.fill")
                                .foregroundColor(theme.accentRed)
                            Text("成语典故")
                                .foregroundColor(theme.primaryText)
                            Spacer()
                        }
                    }

                    NavigationLink(destination: CacheManagementView()) {
                        HStack {
                            Image(systemName: "externaldrive")
                                .foregroundColor(theme.accentRed)
                            Text("缓存管理")
                                .foregroundColor(theme.primaryText)
                            Spacer()
                        }
                    }
                    
                    Button(action: {
                        // Feedback functionality would go here
                    }) {
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(theme.accentRed)
                            Text("反馈建议")
                                .foregroundColor(theme.primaryText)
                            Spacer()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("我的")
            .listStyle(GroupedListStyle())
            .background(
                theme.pageBackground // Soft antique paper background
                    .ignoresSafeArea()
            )
    }
    
    private var privacyPolicyContent: String {
        return """
        隐私政策
        
        本应用尊重并保护用户的个人隐私。我们承诺：
        
        1. 不收集用户的个人信息
        2. 不追踪用户的使用行为
        3. 不向第三方分享任何数据
        4. 所有收藏数据仅存储在您的设备本地
        
        本应用为离线应用，所有音频文件和数据均存储在您的设备中，不会上传到任何服务器。
        """
    }
    
    private var termsOfServiceContent: String {
        return """
        使用协议
        
        欢迎使用红楼聆梦应用！
        
        1. 本应用仅供个人学习和欣赏使用
        2. 请勿将音频内容用于商业用途
        3. 尊重原著版权，不得恶意传播或篡改内容
        4. 应用开发者不对内容准确性承担责任
        
        继续使用本应用即表示您同意以上条款。
        """
    }
    
    // MARK: - Helpers

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(theme.accentRed)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(theme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
    }

    private var aboutContent: String {
        return """
        关于我们
        
        红楼聆梦是一款专注于《红楼梦》有声读物的应用。
        
        • 提供完整的60回有声内容
        • 支持章节收藏功能
        • 离线播放，无需网络
        • 古典美学界面设计
        
        版本：1.0
        开发者：Paul Dexin Gong
        """
    }
}

struct LegalContentView: View {
    @ObservedObject private var theme = ThemeManager.shared
    let title: String
    let content: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(content)
                    .font(.body)
                    .foregroundColor(theme.primaryText)
                    .padding()
            }
            .background(
                theme.pageBackground
                    .ignoresSafeArea()
            )
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    MyAccountView()
}