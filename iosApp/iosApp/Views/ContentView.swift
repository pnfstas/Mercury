//
//  ContentView.swift
//  Mercury
//
//  Created by Panferov Stanislav on 21.07.2026.
//

import SwiftUI

enum AppScreens : Hashable, CaseIterable {
    case main
    case catalog
    case favorites
    case shoppingCart
    case about
    case contacts
    case questions
}

struct ContentView: View {
    @State private var navigationPath = NavigationPath()
    var body: some View {
        NavigationStack(path: $navigationPath) {
            MainView()
                .navigationBarTitleDisplayMode(.automatic)
                .mainToolbar(navigationPath: $navigationPath, navigationTitle: "Главная")
                .navigationDestination(for: AppScreens.self) { screen in
                    switch screen {
                    case .main:
                        MainView()
                            .mainToolbar(navigationPath: $navigationPath, navigationTitle: "Главная")
                     case .catalog:
                        CatalogView()
                            .mainToolbar(navigationPath: $navigationPath, navigationTitle: "Главная")
                    case .favorites:
                        FavoritesView()
                            .mainToolbar(navigationPath: $navigationPath, navigationTitle: "Главная")
                     case .shoppingCart:
                        ShoppingCartView()
                            .mainToolbar(navigationPath: $navigationPath, navigationTitle: "Главная")
                    case .about:
                        AboutView()
                            .mainToolbar(navigationPath: $navigationPath, navigationTitle: "Главная")
                     case .contacts:
                        ContactsView()
                            .mainToolbar(navigationPath: $navigationPath, navigationTitle: "Главная")
                    case .questions:
                        QuestionsView()
                            .mainToolbar(navigationPath: $navigationPath, navigationTitle: "Главная")
                    }
                }
        }
    }
}
/*
#Preview {
    ContentView()
}
*/
