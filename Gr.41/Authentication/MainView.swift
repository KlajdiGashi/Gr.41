import SwiftUI
import Firebase
import Combine

struct Article: Decodable {
    let title: String
    let description: String?
    let url: String
}

class NewsViewModel: ObservableObject {
    @Published var articles: [Article] = []

    init() {
        fetchNews()
    }

    func fetchNews() {
        guard let url = URL(string: "https://newsapi.org/v2/everything?q=apple&from=2024-03-04&to=2024-03-04&sortBy=popularity&apiKey=YOUR_API_KEY") else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("Error fetching news: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let result = try JSONDecoder().decode([String: [Article]].self, from: data)
                if let articles = result["articles"] {
                    DispatchQueue.main.async {
                        self.articles = articles
                    }
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
}

struct MainView: View {
    @State private var showSignInView: Bool = false
    @StateObject private var viewModel = NewsViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    NavigationLink(destination: CompleteView(articles: viewModel.articles)) {
                        BlockView(color: .blue, text: "Block 1")
                            .cornerRadius(8.2)
                    }

                    NavigationLink(destination: CompleteView(articles: viewModel.articles)) {
                        BlockView(color: .green, text: "Block 2")
                            .cornerRadius(8.2)
                    }
                }

                NavigationLink(destination: CompleteView(articles: viewModel.articles)) {
                    BlockView(color: .yellow, text: "Block 3")
                        .cornerRadius(8.2)
                        .frame(height: 120)
                }

                NavigationLink(destination: CompleteView(articles: viewModel.articles)) {
                    BlockView(color: .orange, text: "Block 4")
                        .cornerRadius(10)
                        .frame(height: 120)
                }

                NavigationLink(destination: CompleteView(articles: viewModel.articles)) {
                    BlockView(color: .purple, text: "Block 5")
                        .cornerRadius(8.2)
                        .frame(height: 120)
                }
            }
            .onAppear {
                //    let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
                //    self.showSignInView = authUser == nil
            }
            .padding(.top, -130)
            .padding(20)
            .navigationBarTitle("Main News", displayMode: .inline)
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
    let articles: [Article]

    var body: some View {
        NavigationView {
            List(articles, id: \.title) { article in
                NavigationLink(destination: Text("Detail for \(article.title)")) {
                    CustomRowView(itemName: article.title)
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
