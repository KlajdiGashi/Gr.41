import SwiftUI
import FirebaseAuth

final class EmailConfirmationViewModel: ObservableObject {
    @Published var isEmailVerified: Bool = false

    func checkEmailVerification() async {
        do {
            try await AuthenticationManager.shared.sendEmailVerification()
            isEmailVerified = AuthenticationManager.shared.isEmailVerified()
        } catch {
            print("Error checking email verification: \(error.localizedDescription)")
        }
    }
}

struct EmailConfirmationView: View {
    @StateObject private var viewModel = EmailConfirmationViewModel()
    @State private var isVerified: Bool = false

    @State private var scale: CGFloat = 0.8

    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .foregroundColor(.blue)
                    .frame(width: 150, height: 150)
                    .scaleEffect(scale)
                    .animation(
                        Animation.easeInOut(duration: 1)
                            .repeatForever(autoreverses: true)
                    )

                Image(systemName: "envelope.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.white)
                    .frame(width: 90, height: 90)
                    .animation(
                        Animation.easeInOut(duration: 1)
                            .repeatForever(autoreverses: true)
                    )
            }

            Text("Waiting for email confirmation")
                .font(.title)
                .padding()

            Text("Please click the link in your email to finish setting up your account.")
                .multilineTextAlignment(.center)
                .padding()

            NavigationLink(destination: MainView(), isActive: $isVerified) {
                EmptyView()
            }
            .hidden()
            .onAppear {
                Task {
                    await viewModel.checkEmailVerification()
                    isVerified = viewModel.isEmailVerified
                }
            }
        }
        .navigationBarBackButtonHidden(false)
        .navigationBarTitle("Email Confirmation", displayMode: .inline)
    }
}

struct EmailConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        EmailConfirmationView()
    }
}
