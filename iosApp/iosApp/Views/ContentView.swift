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
    @State private var navigationPath : [AppScreens] = []
    var body: some View {
        NavigationStack {
            MainView()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image("Mercury")
                        .renderingMode(.template)
                        .frame(width: 24, height: 24)
                }
            }

        }
        .navigationDestination(for: AppScreens.self) { screen in
            switch screen {
            case .main: MainView()
            case .catalog: CatalogView()
            case .favorites: FavoritesView()
            case .shoppingCart: ShoppingCartView()
            case .about: AboutView()
            case .contacts: ContactsView()
            case .questions: QuestionsView()
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
