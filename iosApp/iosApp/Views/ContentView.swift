//
//  ContentView.swift
//  Mercury
//
//  Created by Panferov Stanislav on 21.07.2026.
//

import SwiftUI
import shared

enum AppScreens : Hashable, CaseIterable {
    case main
    case catalog
    case favorites
    case trash
    case about
    case contacts
    case faq
}


struct ContentView: View {
    @State private var navigationPath : [AppScreens] = []
    @State private var toolbarIcons : [String : UIImage?] = ["mercury.png" : nil, "catalog.svg" : nil, "search.svg" : nil, "favorites.svg" : nil, "trash.svg" : nil, "menu.svg" : nil ]
    var body: some View {
        NavigationStack {
            MainView()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(uiImage: toolbarIcons["mercury.png"]! ?? UIImage())
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 24, height: 24)
                }
            }

        }
        .navigationDestination(for: AppScreens.self) { screen in
            switch screen {
            case .main: MainView()
            case .catalog:
            case .favorites:
            case .trash:
            case .about:
            case .contacts:
            case .faq:
            }
        }
        .task {
            for key in toolbarIcons.keys {
                toolbarIcons[key] = await ResourceLoaderKt.loadSharedDrawable(key)
            }
        }
        Grid(horizontalSpacing : 10, verticalSpacing : 10) {
            
        }
    }
}
/*
 #Preview {
 ContentView()
 }
*/
