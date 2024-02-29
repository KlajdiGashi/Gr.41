import SwiftUI
import Firebase


struct MainView: View {
    @State private var showSignInView: Bool = false
    	
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                
                HStack(spacing: 10) {
                    NavigationLink(destination: CompleteView()) {
                        BlockView(color:.blue,text:"Block 1")
                            .cornerRadius(8.2)
                    }
                    
                    NavigationLink(destination: CompleteView()) {
                        BlockView(color: .green,text:"Block 2")
                            .cornerRadius(8.2)
                    }
                }
                
                
                NavigationLink(destination: CompleteView()) {
                    BlockView(color: .yellow,text:"Block 3")
                        .cornerRadius(8.2)
                        .frame(height: 120)
                }
                    
                
                NavigationLink(destination: CompleteView()) {
                    BlockView(color: .orange,text:"Block 4")
                        .cornerRadius(10)
                        .frame(height: 120)
                }
                
                
                NavigationLink(destination: CompleteView()) {
                    BlockView(color: .purple,text:"Block 5")
                        .cornerRadius(8.2)
                        .frame(height: 120)
                }
            }
            
            .onAppear{
            //    let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            //    self.showSignInView = authUser == nil
            }
            .padding(.top,-130)
            .padding(20)
            .navigationBarTitle("Main News",displayMode: .inline)
            .navigationBarItems(trailing:
                                    NavigationLink(destination: SettingsView(showSigningView: .constant(false))) {
                                    Image(systemName: "gearshape.fill")
                                    .resizable()	
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.blue)
                                    .padding()
                            }
                        )
            
            	
        }	
        .navigationBarBackButtonHidden(true)
        
        	

    }
        
}

struct CustomRowView: View {
    var itemName: String

    var body: some View {
        HStack {
            Image(systemName: "square.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(.blue)

            Text(itemName)
                .font(.headline)
                .padding(.leading, 10)
            
            Spacer()

            Image(systemName: "arrow.right.circle.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(.green)
        }
        .padding(10)
    }
}

struct CompleteView: View {
    let items = ["Item 1", "Item 2", "Item 3", "Item 4"]
      
      var body: some View {
          NavigationView {
              List(items, id: \.self) { item in
                  NavigationLink(destination: Text("Detail for \(item)")) {
                      CustomRowView(itemName: item)
                  }
              }
              .navigationBarTitle("Custom Table View")
          }
          
      }
        
    }

 

struct BlockView: View {
    var color: Color
    var text: String
    
    init(color: Color = .blue, text: String) {
        self.color = color
        self.text = text
    }

    var body: some View {
        VStack {
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(color)
                    .border(Color.black, width: 1)
                    .cornerRadius(10)
                    .frame(height: 100)
                
                Image(systemName: "newspaper.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 20)
                    .foregroundColor(.white)
                    .padding(.top, 5)
                    .padding(10)
            }
            
            Text(text)
                .foregroundColor(.white)
        }
    }
}


struct MainView_Preview: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MainView()
        }
    }
}
