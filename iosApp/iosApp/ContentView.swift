//
//  ContentView.swift
//  Mercury
//
//  Created by Panferov Stanislav on 21.07.2026.
//

import SwiftUI
import WebKit

struct ContentView: View {
    var body: some View {
        // Вызываем наш WebView и передаем адрес вашего сайта/сервера
        MyWebView(urlString: "https://mercury-food-store.tilda.ws/")
            .ignoresSafeArea(.all) // Растягиваем браузер на весь экран айфона
    }
}
struct MyWebView: UIViewRepresentable {
    let urlString: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
}
/*
#Preview {
    ContentView()
}
*/
