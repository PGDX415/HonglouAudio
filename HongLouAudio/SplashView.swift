import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var opacity = 0.0
    @State private var scale = 0.8
    
    var body: some View {
        ZStack {
            // Modern gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.15, green: 0.15, blue: 0.3),
                    Color(red: 0.25, green: 0.1, blue: 0.4),
                    Color(red: 0.4, green: 0.1, blue: 0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Chinese title
                Text("红楼聆梦")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: Color.white.opacity(0.3), radius: 8, x: 0, y: 4)
                    .opacity(opacity)
                    .scaleEffect(scale)
                
                // Animated logo using start image
                if let uiImage = UIImage(named: "start") {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                        .opacity(opacity)
                        .scaleEffect(scale)
                } else {
                    // Fallback to text if image not found
                    Text("红楼聆梦")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: Color.white.opacity(0.3), radius: 10, x: 0, y: 5)
                        .opacity(opacity)
                        .scaleEffect(scale)
                }
                
                // English subtitle
                Text("Dream of the Red Chamber")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .opacity(opacity)
                
                // Animated progress indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                    .opacity(isActive ? 0 : 1)
            }
            .onAppear {
                // Animation sequence
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeOut(duration: 1.0)) {
                        opacity = 1.0
                        scale = 1.0
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeIn(duration: 0.5)) {
                        isActive = true
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            MainTabView()
        }
    }
}

#Preview {
    SplashView()
}