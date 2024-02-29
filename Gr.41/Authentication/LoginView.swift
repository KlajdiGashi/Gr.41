
import SwiftUI
import Firebase

final class LoginEmailVieModel:ObservableObject{
    @Published var email = ""
    @Published var password = ""
    
    
    func SignIn() async{
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found")
                return
        }
        do {
            try await AuthenticationManager.shared.SignIn(email: email, password: password)
        }
        catch{
            print("Login error:\(error.localizedDescription)")
        }
        
    }
    
    
}


struct LoginView: View {
    
    @StateObject private var viewModel=LoginEmailVieModel()
    @State private var showSignInView: Bool = false
  
    
    @State private var isPasswordVisible: Bool = false
    @State private var isLogged: Bool = false
    
    
    var body: some View {
            NavigationView {
            VStack {
                Image(systemName: "books.vertical.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                    .padding(.top,100)
                    .padding(.bottom,15)
                
                Spacer()
                    .frame(height: 15)
                    
                
                TextField("Email", text:$viewModel.email)
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    .padding()
                    .font(.system(size: 22))
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                
                ZStack(alignment: .trailing) {
                    if isPasswordVisible {
                        TextField("Password", text: $viewModel.password)
                            .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                            .padding()
                            .font(.system(size: 20))
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            
                            .overlay(
                                Button(action: {
                                    isPasswordVisible.toggle()
                                }) {
                                    Image(systemName: "eye.fill")
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 23)
                                }
                                .padding(.leading, 8),
                                alignment: .trailing
                            )
                    } else {
                        SecureField("Password", text: $viewModel.password)
                            .autocapitalization(.none)
                            .padding()
                            .font(.system(size: 20))
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .overlay(
                                Button(action: {
                                    isPasswordVisible.toggle()
                                }) {
                                    Image(systemName: "eye.slash.fill")
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 23)
                                }
                                .padding(.leading, 8),
                                alignment: .trailing
                            )
                    }
                }
                .navigationBarBackButtonHidden(true)
                
                Spacer()
                    .frame(height: 40)
                
                Button(action: {
                    Task {
                        do {
        
                            let authResult = try await AuthenticationManager.shared.SignIn(email: viewModel.email, password: viewModel.password)
                            print("Login successful for user with UID: \(authResult.uid)")
                            
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.5)){
                                isLogged = true
                            }
                        } catch {
                            print("Login error: \(error.localizedDescription)")
                        }
                    }	
                    
                }) {
                    Text("Login")
                        .foregroundColor(.white)
                        .padding()
                        .font(.system(size: 24))
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                        .frame(width: 370, height: 100)
                }
                
                NavigationLink(destination: MainView(), isActive: $isLogged) {
                    EmptyView()
                }
                .hidden()
                .onTapGesture {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.5)){
                        isLogged = true
                    }
                }
                HStack{
                    NavigationLink(destination: ResetPasswordView()) {
                    Text("Forgot Password?")
                        .foregroundColor(.blue)
                        .padding(.top,-10)
                    
                    }
                    Spacer()
                    
                    NavigationLink(destination:SignupView()){
                        Text("Sign Up")
                            .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                            .padding(.top,-10)
                    }
                    .navigationBarBackButtonHidden(true)
                }
                .navigationBarBackButtonHidden(true)
                Spacer()
            }
            	
            .padding()
            .navigationBarTitle("Login", displayMode: .inline)
            .onAppear{
            //    let authuser=try? AuthenticationManager.shared.getAuthenticatedUser()
            //    self.showSignInView = authuser == nil
            }

        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true)
        
        
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
