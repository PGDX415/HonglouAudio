//
//  MyAccountView.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/3/31.
//

import SwiftUI

struct MyAccountView: View {
    @State private var playbackSpeed: Float = 1.0
    @State private var volume: Float = 0.8
    
    var body: some View {
        NavigationView {
            List {
                Section("账户信息") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "person.circle")
                                .font(.title)
                                .foregroundColor(Color(red: 0.6, green: 0.2, blue: 0.2)) // Classical red
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("红楼聆梦用户")
                                    .font(.headline)
                                    .foregroundColor(Color(red: 0.2, green: 0.1, blue: 0.1))
                                
                                Text("guest@example.com")
                                    .font(.caption)
                                    .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.2))
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
                                .foregroundColor(Color(red: 0.2, green: 0.1, blue: 0.1))
                            Spacer()
                            Text("\(playbackSpeed, specifier: "%.1fx")")
                                .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.2))
                        }
                        
                        Slider(value: $playbackSpeed, in: 0.5...2.0, step: 0.1)
                            .accentColor(Color(red: 0.6, green: 0.2, blue: 0.2))
                        
                        HStack {
                            Text("音量控制")
                                .foregroundColor(Color(red: 0.2, green: 0.1, blue: 0.1))
                            Spacer()
                            Text("\(Int(volume * 100))%")
                                .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.2))
                        }
                        
                        Slider(value: $volume, in: 0.0...1.0, step: 0.05)
                            .accentColor(Color(red: 0.6, green: 0.2, blue: 0.2))
                    }
                    .padding(.vertical, 4)
                }
                
                Section("法律与隐私") {
                    NavigationLink(destination: LegalContentView(title: "隐私政策", content: privacyPolicyContent)) {
                        HStack {
                            Image(systemName: "lock.shield")
                                .foregroundColor(Color(red: 0.6, green: 0.2, blue: 0.2))
                            Text("隐私政策")
                                .foregroundColor(Color(red: 0.2, green: 0.1, blue: 0.1))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.2))
                        }
                    }
                    
                    NavigationLink(destination: LegalContentView(title: "使用协议", content: termsOfServiceContent)) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(Color(red: 0.6, green: 0.2, blue: 0.2))
                            Text("使用协议")
                                .foregroundColor(Color(red: 0.2, green: 0.1, blue: 0.1))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.2))
                        }
                    }
                }
                
                Section("其他") {
                    NavigationLink(destination: LegalContentView(title: "关于我们", content: aboutContent)) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(Color(red: 0.6, green: 0.2, blue: 0.2))
                            Text("关于我们")
                                .foregroundColor(Color(red: 0.2, green: 0.1, blue: 0.1))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.2))
                        }
                    }
                    
                    Button(action: {
                        // Clear cache functionality would go here
                        // For now, just show an alert or perform the action
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(Color(red: 0.6, green: 0.2, blue: 0.2))
                            Text("清除缓存")
                                .foregroundColor(Color(red: 0.2, green: 0.1, blue: 0.1))
                            Spacer()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        // Feedback functionality would go here
                    }) {
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(Color(red: 0.6, green: 0.2, blue: 0.2))
                            Text("反馈建议")
                                .foregroundColor(Color(red: 0.2, green: 0.1, blue: 0.1))
                            Spacer()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("我的")
            .listStyle(GroupedListStyle())
            .background(
                Color(red: 0.98, green: 0.96, blue: 0.92) // Soft antique paper background
                    .ignoresSafeArea()
            )
        }
        .accentColor(Color(red: 0.6, green: 0.2, blue: 0.2)) // Classical red accent
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
    let title: String
    let content: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(content)
                    .font(.body)
                    .foregroundColor(Color(red: 0.2, green: 0.1, blue: 0.1))
                    .padding()
            }
            .background(
                Color(red: 0.98, green: 0.96, blue: 0.92)
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