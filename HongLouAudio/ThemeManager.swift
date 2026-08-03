import SwiftUI
import Combine

final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var isDarkMode: Bool = UserDefaults.standard.bool(forKey: "isDarkMode") {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }

    // MARK: - Semantic Colors

    /// 页面背景色
    var pageBackground: Color {
        isDarkMode
            ? Color(red: 0.08, green: 0.06, blue: 0.05)
            : Color(red: 0.98, green: 0.96, blue: 0.92)
    }

    /// 卡片/列表行背景
    var cardBackground: Color {
        isDarkMode
            ? Color(red: 0.13, green: 0.10, blue: 0.08)
            : Color(red: 0.96, green: 0.94, blue: 0.90)
    }

    /// 正文阅读区背景
    var readingBackground: Color {
        isDarkMode
            ? Color(red: 0.11, green: 0.09, blue: 0.07)
            : Color(red: 0.99, green: 0.97, blue: 0.93)
    }

    /// 按钮/标签背景
    var buttonBackground: Color {
        isDarkMode
            ? Color(red: 0.22, green: 0.18, blue: 0.14)
            : Color(red: 0.92, green: 0.88, blue: 0.80)
    }

    /// 正文主文字色
    var primaryText: Color {
        isDarkMode
            ? Color(red: 0.82, green: 0.78, blue: 0.68)
            : Color(red: 0.2, green: 0.1, blue: 0.1)
    }

    /// 次要文字色
    var secondaryText: Color {
        isDarkMode
            ? Color(red: 0.55, green: 0.50, blue: 0.42)
            : Color(red: 0.4, green: 0.3, blue: 0.2)
    }

    /// 三级文字 / 标签
    var tertiaryText: Color {
        isDarkMode
            ? Color(red: 0.40, green: 0.36, blue: 0.30)
            : Color(red: 0.5, green: 0.3, blue: 0.2)
    }

    /// 主题红色（不变）
    var accentRed: Color {
        Color(red: 0.6, green: 0.2, blue: 0.2)
    }

    /// 深红
    var deepRed: Color {
        isDarkMode
            ? Color(red: 0.7, green: 0.25, blue: 0.25)
            : Color(red: 0.35, green: 0.02, blue: 0.02)
    }

    /// 高亮背景
    var highlightBackground: Color {
        accentRed.opacity(0.1)
    }

    /// 高亮文字
    var highlightText: Color {
        accentRed
    }

    /// 分隔线
    var divider: Color {
        isDarkMode
            ? Color(red: 0.72, green: 0.60, blue: 0.32).opacity(0.15)
            : Color(red: 0.78, green: 0.65, blue: 0.35).opacity(0.12)
    }

    /// 阴影
    var shadowColor: Color {
        isDarkMode ? .clear : Color.black.opacity(0.04)
    }

    /// 导航栏红色
    var navAccent: Color {
        accentRed
    }
}
