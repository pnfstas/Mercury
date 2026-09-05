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
    var description : String {
        return switch self {
        case .main: "Главная"
        case .catalog: "Каталог"
        case .favorites: "Избранное"
        case .shoppingCart: "Корзина"
        case .about: "Об организации"
        case .contacts: "Контакты"
        case .questions: "Частые вопросы"
        }
    }
    var buttonImageName : String {
        return switch self {
        case .catalog: "Catalog"
        case .favorites: "Favorites"
        case .shoppingCart: "ShoppingCart"
        default: ""
        }
    }
    var buttonBackgroundColor : Color {
        return switch self {
        case .catalog: .main
        default: .clear
        }
    }
    var buttonForegroundColor : Color {
        return switch self {
        case .catalog: Color.white
        default: Color.black
        }
    }
 }

struct ContentView: View {
    @State private var navigationPath : [AppScreens] = []
    @State private var productsViewModel : ProductsViewModel = ProductsViewModel()
    var body: some View {
        NavigationStack(path: $navigationPath) {
            MainView(navigationPath: $navigationPath)
                .navigationBarTitleDisplayMode(.automatic)
                .mainToolbar(navigationPath: $navigationPath)
                .navigationDestination(for: AppScreens.self) { screen in
                    Group {
                        switch screen {
                        case .main:
                            MainView(navigationPath: $navigationPath)
                        case .catalog:
                            CatalogView(productsViewModel: $productsViewModel)
                        case .favorites:
                            FavoritesView()
                        case .shoppingCart:
                            ShoppingCartView()
                        case .about:
                            AboutView()
                        case .contacts:
                            ContactsView()
                        case .questions:
                            QuestionsView()
                        }
                    }
                    .mainToolbar(navigationPath: $navigationPath)
                }
        }
    }
}
/*
#Preview {
    ContentView()
}
*/
