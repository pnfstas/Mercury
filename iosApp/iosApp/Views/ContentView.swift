//
//  ContentView.swift
//  Mercury
//
//  Created by Panferov Stanislav on 21.07.2026.
//

import SwiftUI

/*
enum AppScreens : Hashable, CaseIterable {
    case main
    case catalog
    case favorites
    case shoppingCart
    case orders
    case about
    case contacts
    case questions
    var description : String {
        return switch self {
        case .main: "Главная"
        case .catalog: "Каталог"
        case .favorites: "Избранное"
        case .shoppingCart: "Корзина"
        case .orders: "Заказы"
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
        case .orders: "OrderList"
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

class AppRouter : ObservableObject {
    @Published var mercuryShopViewModel : MercuryShopViewModel = MercuryShopViewModel()
    @Published var navigationPath : [AppScreens] = []
    @Published var currentScreen : AppScreens.main
    @Published var isMenuOpen : Bool = false
    @Published var isShoppingCartOpen : Bool = false
    @Published var isOrderListOpen : Bool = false
    @Published var isOrderOpen : Bool = false
    @Published var isOrderItemsOpen : Bool = false
}
*/

struct ContentView: View {
    @State private var viewModel : MercuryShopViewModel = MercuryShopViewModel()
    var body: some View {
        @Bindable var viewModel : MercuryShopViewModel = viewModel
        NavigationStack(path: $viewModel.navigationPath) {
            MainView()
                .navigationBarTitleDisplayMode(.automatic)
                .mainToolbar()
                .navigationDestination(for: AppScreens.self) { screen in
                    Group {
                        switch screen {
                        case .main:
                            MainView()
                        case .catalog:
                            CatalogView()
                        case .favorites:
                            FavoritesView()
                        case .shoppingCart:
                            EmptyView()
                        case .orders:
                            EmptyView()
                        case .about:
                            AboutView()
                        case .contacts:
                            ContactsView()
                        case .questions:
                            QuestionsView()
                        }
                    }
                    .mainToolbar()
                }
        }
        .environment(viewModel)
        .shoppingCart()
    }
}
/*
#Preview {
    ContentView()
}
*/
