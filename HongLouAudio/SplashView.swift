import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    
    var body: some View {
        ZStack {
            // Background image - using "start" image
            if let startImage = UIImage(named: "start") {
                Image(uiImage: startImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
            } else {
                // Fallback background if "start" image doesn't exist
                Color.black
                    .ignoresSafeArea()
            }
            
            // Keep only the progress indicator
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
                .opacity(isActive ? 0 : 1)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeIn(duration: 0.5)) {
                    isActive = true
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