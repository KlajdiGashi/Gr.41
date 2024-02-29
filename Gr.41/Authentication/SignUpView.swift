import SwiftUI
import Firebase
import FirebaseAuth

@MainActor
final class SignupViewModel: ObservableObject{
    @Published var name = ""
    @Published var phonenumber = ""
    @Published var username = ""
    @Published var email = ""
    @Published var password =	 ""
    @Published var confirmpassword = ""
        
 
    func SignUp(){
        
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found")
            return
        }
     Task {
            do {
             
                let hashedPassword = try await AuthenticationManager.shared.hashPassword(password: password)
                
                let returnedUserData = try await AuthenticationManager.shared.createUser(email: email, password: password)

                
                let documentPath = "users/\(returnedUserData.uid)"
                try await AuthenticationManager.shared.updateDocumentIfExistOrCreate(documentPath, data: [
                    "email": email,
                    "password": hashedPassword,
                   
                ])

                print("Success")
                print(returnedUserData)

                try await AuthenticationManager.shared.sendEmailVerification()

                } catch {
                print("error: \(error)")
            }
        }
    }
    
    
    func sendEmailVerification() {
            Task {
                do {
                    try await AuthenticationManager.shared.sendEmailVerification()
                } 
                catch {
                    print("error: \(error)")
                }
            }
        }
    
    
}
    

struct SignupView:View {
    @StateObject private var viewmodel=SignupViewModel()
    
    @State private var isAccountCreate: Bool=false
    @State private var isPasswordVisible: Bool = false
    
    
    var body: some View {
        
        VStack(){
        
            Spacer()
                .frame(height:10)
            
            TextField("Email",text:$viewmodel.email)
                .padding()
                .font(.system(size: 22))
                .frame(width: 370)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            
            
            Spacer()
                .frame(height: 10)
            
            ZStack(alignment: .trailing) {
                if isPasswordVisible {
                    TextField("Password", text: $viewmodel.password)
                        .autocapitalization(.none)
                        .padding()
                        .font(.system(size: 22))
                        .frame(width: 370)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .overlay(
                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                Image(systemName: "eye.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 19)
                            }
                            .padding(.trailing, 8),
                            alignment: .trailing
                        )
                 } else {
                    SecureField("Password", text: $viewmodel.password)
                        .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                        .padding()
                        .font(.system(size: 22))
                        .frame(width: 370)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .overlay(
                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                Image(systemName: "eye.slash.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 19)
                            }
                            .padding(.trailing, 8),
                            alignment: .trailing
                        )
                }
            }
            Spacer()
                .frame(height: 10)
                .navigationBarBackButtonHidden(true)
            
            Spacer()
                .frame(height: 10)
            
            
            NavigationLink(destination: EmailConfirmationView(), isActive: $isAccountCreate) {
                        EmptyView()
                    }
                .hidden()
            
            Button	{
                viewmodel.SignUp()
                isAccountCreate=true
            }label: {
                Text("Create Account")
                    .foregroundColor(.white)
                    .padding()
                    .font(.system(size: 24))
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
                    .frame(width: 300, height: 50)
            }
                        .padding(.top, 20)
                        NavigationLink(destination: MainView()) {
                            EmptyView()  }
                .hidden()
            
            Spacer()
            
            HStack{
                NavigationLink(destination:LoginView()){
                    Text("Already have an account?")
                        .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                }
                
            }
        }
        .padding()
        .navigationBarTitle("Sign Up", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
                   
    }
        
        
            }
struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
            NavigationStack {
                    SignupView()
        }
    }
}
