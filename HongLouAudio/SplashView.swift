import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var titleOpacity = 0.0
    @State private var sealOpacity = 0.0
    @State private var subtitleOpacity = 0.0
    @State private var loaderOpacity = 0.0

    // Classical Chinese color palette — fixed for brand identity
    private let vermillionRed = Color(red: 0.55, green: 0.08, blue: 0.08)
    private let deepRed = Color(red: 0.35, green: 0.02, blue: 0.02)
    private let antiqueGold = Color(red: 0.78, green: 0.65, blue: 0.35)
    private let creamWhite = Color(red: 0.96, green: 0.93, blue: 0.86)
    private let inkBlack = Color(red: 0.12, green: 0.08, blue: 0.05)

    var body: some View {
        ZStack {
            if isActive {
                MainTabView()
            } else {
                // Background: use splash_bg image if available, fallback to gradient
                ZStack {
                    // Background layer
                    if let bgImage = UIImage(named: "splash_bg") {
                        Image(uiImage: bgImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .ignoresSafeArea()
                    } else {
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.48, green: 0.06, blue: 0.06),
                                deepRed,
                                Color(red: 0.28, green: 0.01, blue: 0.01)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .ignoresSafeArea()

                        // Cloud pattern — only when no background image
                        GeometryReader { geo in
                            Path { path in
                                let w = geo.size.width
                                let h = geo.size.height
                                path.move(to: CGPoint(x: -w * 0.1, y: h * 0.25))
                                path.addCurve(to: CGPoint(x: w * 0.3, y: h * 0.28),
                                              control1: CGPoint(x: w * 0.05, y: h * 0.15),
                                              control2: CGPoint(x: w * 0.2, y: h * 0.35))
                                path.addCurve(to: CGPoint(x: w * 1.1, y: h * 0.22),
                                              control1: CGPoint(x: w * 0.5, y: h * 0.18),
                                              control2: CGPoint(x: w * 0.8, y: h * 0.30))
                            }
                            .stroke(creamWhite.opacity(0.04), lineWidth: 1.5)

                            Path { path in
                                let w = geo.size.width
                                let h = geo.size.height
                                path.move(to: CGPoint(x: w * 0.2, y: h * 0.72))
                                path.addCurve(to: CGPoint(x: w * 0.6, y: h * 0.74),
                                              control1: CGPoint(x: w * 0.35, y: h * 0.68),
                                              control2: CGPoint(x: w * 0.5, y: h * 0.78))
                                path.addCurve(to: CGPoint(x: w * 1.2, y: h * 0.70),
                                              control1: CGPoint(x: w * 0.8, y: h * 0.68),
                                              control2: CGPoint(x: w * 1.0, y: h * 0.76))
                            }
                            .stroke(creamWhite.opacity(0.03), lineWidth: 1.5)
                        }
                    }

                    // Text and seal overlay
                    VStack(spacing: 0) {
                        Spacer()

                        // —— 印章 ——
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(antiqueGold, lineWidth: 2)
                                .frame(width: 72, height: 72)
                                .rotationEffect(.degrees(45))
                            RoundedRectangle(cornerRadius: 2)
                                .stroke(antiqueGold.opacity(0.6), lineWidth: 1)
                                .frame(width: 62, height: 62)
                                .rotationEffect(.degrees(45))
                            Text("梦")
                                .font(.system(size: 30, weight: .bold, design: .serif))
                                .foregroundColor(antiqueGold)
                        }
                        .opacity(sealOpacity)
                        .scaleEffect(sealOpacity)

                        Spacer().frame(height: 32)

                        // —— 书名 ——
                        VStack(spacing: 2) {
                            Text("红楼梦")
                                .font(.system(size: 46, weight: .bold, design: .serif))
                                .foregroundColor(creamWhite)
                                .shadow(color: Color.black.opacity(0.5), radius: 4, x: 0, y: 2)
                        }
                        .opacity(titleOpacity)

                        Spacer().frame(height: 8)

                        // —— 金线分隔 ——
                        HStack(spacing: 10) {
                            Rectangle()
                                .fill(antiqueGold.opacity(0.5))
                                .frame(width: 40, height: 1)
                            Circle()
                                .fill(antiqueGold)
                                .frame(width: 5, height: 5)
                            Rectangle()
                                .fill(antiqueGold.opacity(0.5))
                                .frame(width: 40, height: 1)
                        }
                        .opacity(titleOpacity)

                        Spacer().frame(height: 10)

                        // —— 副标题 / 开篇词 ——
                        VStack(spacing: 6) {
                            Text("满纸荒唐言")
                                .font(.system(size: 16, design: .serif))
                                .foregroundColor(creamWhite.opacity(0.7))
                            Text("一把辛酸泪")
                                .font(.system(size: 16, design: .serif))
                                .foregroundColor(creamWhite.opacity(0.7))
                        }
                        .opacity(subtitleOpacity)

                        Spacer().frame(height: 40)

                        // —— 底部署名 ——
                        Text("—  有声珍藏版  —")
                            .font(.system(size: 12, design: .serif))
                            .foregroundColor(creamWhite.opacity(0.4))
                            .tracking(4)
                            .opacity(subtitleOpacity)

                        Spacer().frame(height: 50)

                        // —— 加载指示 ——
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: antiqueGold))
                            .scaleEffect(0.9)
                            .opacity(loaderOpacity)

                        Spacer().frame(height: 60)
                    }
                    .padding(.horizontal, 32)
                }
            }
        }
        .onAppear {
            guard !isActive else { return }

            // 印章先入
            withAnimation(.easeOut(duration: 0.9).delay(0.2)) {
                sealOpacity = 1.0
            }
            // 书名随后
            withAnimation(.easeOut(duration: 1.0).delay(0.6)) {
                titleOpacity = 1.0
            }
            // 副标题渐显
            withAnimation(.easeOut(duration: 1.0).delay(1.0)) {
                subtitleOpacity = 1.0
            }
            // 加载指示
            withAnimation(.easeOut(duration: 0.5).delay(1.5)) {
                loaderOpacity = 0.6
            }

            // 跳转主页
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.default) {
                    isActive = true
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
