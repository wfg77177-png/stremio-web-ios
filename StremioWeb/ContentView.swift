import SwiftUI
import WebKit

// Stremio 官方网页版
let serverURL = "https://web.stremio.com"

class WebViewModel: NSObject, ObservableObject, WKNavigationDelegate, WKUIDelegate {
    @Published var isLoading = true
    @Published var loadFailed = false
    @Published var reloadToken = 0
    weak var webView: WKWebView?

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isLoading = false
        loadFailed = false
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        isLoading = false
        loadFailed = true
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        isLoading = false
        loadFailed = true
    }

    // 新窗口链接（target=_blank）在同一个 WebView 里打开，不让点着没反应
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url {
            webView.load(URLRequest(url: url))
        }
        return nil
    }
}

struct WebView: UIViewRepresentable {
    let url: String
    @ObservedObject var model: WebViewModel

    func makeCoordinator() -> WebViewModel { model }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        let wv = WKWebView(frame: .zero, configuration: config)
        wv.navigationDelegate = context.coordinator
        wv.uiDelegate = context.coordinator
        wv.allowsBackForwardNavigationGestures = true
        wv.isOpaque = false
        wv.backgroundColor = .black
        model.webView = wv
        if let u = URL(string: url) {
            wv.load(URLRequest(url: u))
        }
        return wv
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if model.reloadToken > 0 {
            if let u = URL(string: url) {
                uiView.load(URLRequest(url: u))
            }
            DispatchQueue.main.async {
                model.reloadToken = 0
                model.isLoading = true
                model.loadFailed = false
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var model = WebViewModel()

    var body: some View {
        ZStack {
            WebView(url: serverURL, model: model)
                .ignoresSafeArea(edges: .bottom)
            if model.isLoading {
                Color.black
                    .ignoresSafeArea()
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                    Text("正在加载…")
                        .foregroundColor(.white)
                        .font(.subheadline)
                }
            }
            if model.loadFailed {
                Color.black
                    .ignoresSafeArea()
                VStack(spacing: 16) {
                    Image(systemName: "wifi.exclamationmark")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    Text("打不开 Stremio")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("请检查网络连接，\n然后点下面重试。")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    Button("重新加载") {
                        model.reloadToken = 1
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
        .navigationTitle("Stremio")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    model.reloadToken = 1
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if let u = URL(string: serverURL) {
                        UIApplication.shared.open(u)
                    }
                }) {
                    Image(systemName: "safari")
                }
            }
        }
    }
}
