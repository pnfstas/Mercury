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
        NavigationStack(path: $navigationPath) {
            MainView()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image("Mercury")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 140, height: 70)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {navigationPath.append(.catalog)}) {
                        HStack {
                            Image("Catalog")
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 22, height: 22)
                            Text("Каталог")
                                .foregroundStyle(.white)
                                .font(.custom("Arial", size: 14).bold())
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .buttonBorderShape(.roundedRectangle(radius: 8))
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
    }
}
/*
#Preview {
    ContentView()
}
*/
