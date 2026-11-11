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
        NavigationStack(path: $viewModel.navigationPath) {
            MainView(mercuryViewModel: viewModel)
                .navigationBarTitleDisplayMode(.automatic)
                .mainToolbar(mercuryViewModel : viewModel)
                .navigationDestination(for: AppScreens.self) { screen in
                    Group {
                        switch screen {
                        case .main:
                            MainView(mercuryViewModel: viewModel)
                        case .catalog:
                            CatalogView(mercuryViewModel: viewModel)
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
                    .mainToolbar(mercuryViewModel : viewModel)
                }
        }
        .measureScreen()
        .orderList(viewModel: viewModel)
        .shoppingCart(viewModel: viewModel)
        .order(viewModel: viewModel)
        .onAppear {
            viewModel.observeShopUIStates()
            viewModel.observeCartUIStates()
            viewModel.observeOrderUIStates()
        }
     }
}
