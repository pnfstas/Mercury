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
                .navigationBarTitleDisplayMode(.automatic)
                .toolbar(.hidden, for: .navigationBar)
                .safeAreaInset(edge: .top, spacing: 0) {
                    HStack(alignment: .center) {
                        if !navigationPath.isEmpty {
                            
                        }
                        Spacer()
                        HStack(alignment: .center) {
                            Image("Mercury")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 88, height: 44)
                            Button(action: {navigationPath.append(.catalog)}) {
                                HStack {
                                    Image("Catalog")
                                        .resizable()
                                        .renderingMode(.template)
                                        .frame(width: 22, height: 22)
                                    Text("Каталог")
                                        .font(.system(size: 14, weight: .bold))
                                }
                                .padding(.horizontal, 7)
                                .padding(.vertical, 5)
                                .foregroundStyle(.white)
                                .background(RoundedRectangle(cornerRadius: 8).fill(.blue))
                            }
                            .buttonStyle(.plain)
                        }
                        .background(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .background(.white)
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
}
/*
#Preview {
    ContentView()
}
*/
