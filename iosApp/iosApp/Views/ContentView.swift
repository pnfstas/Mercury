//
//  ContentView.swift
//  Mercury
//
//  Created by Panferov Stanislav on 21.07.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel : MercuryShopViewModel = MercuryShopViewModel()
    var body: some View {
        let content =
        NavigationStack(path: $viewModel.navigationPath) {
            MainView()
                .navigationBarTitleDisplayMode(.automatic)
                //.environment(viewModel)
                .mainToolbar(mercuryViewModel : viewModel)
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
                    //.environment(viewModel)
                    .mainToolbar(mercuryViewModel : viewModel)
                }
        }
        .environment(viewModel)
        if viewModel.isShoppingCartOpen {
            content
                .shoppingCart(mercuryViewModel: viewModel)
        }
        else if viewModel.isOrderListOpen {
            content
                .orderList(mercuryViewModel: viewModel)
        }
        else if viewModel.isOrderOpen {
            content
                .order(mercuryViewModel: viewModel)
        }
    }
}
/*
#Preview {
    ContentView()
}
*/
