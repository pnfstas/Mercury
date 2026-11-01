//
//  MainToolbarModifier.swift
//  iosApp
//
//  Created by Panferov Stanislav on 17.08.2026.
//

import SwiftUI

struct MainToolbarModifier : ViewModifier {
    @Environment(MercuryShopViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    func body(content: Content) -> some View {
        @Bindable var viewModel : MercuryShopViewModel = viewModel
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top, spacing: 0) {
                VStack(alignment: .center, spacing: 0) {
                    HStack(alignment: .center) {
                        if viewModel.navigationPath.count > 0 {
                            Button(action: {viewModel.navigationPath.removeLast()}) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.black)
                            }
                            .buttonStyle(.plain)
                        }
                        Spacer()
                        HStack(alignment: .center, spacing: 1) {
                            MainToolbarButton(appScreen: AppScreens.catalog, action: { viewModel.navigationPath.append(AppScreens.catalog) })
                            MainToolbarButton(appScreen: AppScreens.favorites, action: { viewModel.navigationPath.append(AppScreens.favorites) })
                            MainToolbarButton(appScreen: AppScreens.shoppingCart, action: { viewModel.isShoppingCartOpen.toggle() })
                            MainToolbarButton(appScreen: AppScreens.orders, action: { viewModel.isOrderOpen.toggle() })
                            Group {
                                if viewModel.isMenuOpen {
                                    MainToolbarButton(systemName: "multiply", description: "Меню", fgColor: .black, bkColor: .clear,
                                                      action: { viewModel.isMenuOpen.toggle() })
                                    .font(.system(size: 20, weight: .semibold))
                                }
                                else {
                                    MainToolbarButton(imageName: "Menu", description: "Меню", fgColor: .black, bkColor: .clear,
                                                      action: { viewModel.isMenuOpen.toggle() })
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    HStack {
                        Image("Mercury")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 88, height: 44)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    Divider()
                }
                .background(.menu)
                .environment(viewModel)
                .mainToolbarMenu()
            }
            .frame(maxWidth: .infinity, alignment: .top)
            //.mainToolbarMenu(navigationPath: $navigationPath, isMenuOpen: $isMenuOpen)
            .navigationTitle(viewModel.navigationPath.last?.description ?? "")
            .navigationBarBackButtonHidden(viewModel.navigationPath.count > 0)
        
    }
}
extension View {
    func mainToolbar() -> some View {
        modifier(MainToolbarModifier())
    }
}
