//
//  MainToolbarModifier.swift
//  iosApp
//
//  Created by Panferov Stanislav on 17.08.2026.
//

import SwiftUI

struct MainToolbarModifier : ViewModifier {
    @Binding var navigationPath : [AppScreens]
    @Environment(\.dismiss) private var dismiss
    @State private var isMenuOpen : Bool = false
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top, spacing: 0) {
                VStack(alignment: .center, spacing: 0) {
                    HStack(alignment: .center) {
                        if navigationPath.count > 0 {
                            Button(action: {navigationPath.removeLast()}) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.black)
                            }
                            .buttonStyle(.plain)
                        }
                        Spacer()
                        HStack(alignment: .center, spacing: 1) {
                            MainToolbarButton(appScreen: AppScreens.catalog, action: {navigationPath.append(AppScreens.catalog)})
                            MainToolbarButton(appScreen: AppScreens.favorites, action: {navigationPath.append(AppScreens.favorites)})
                            MainToolbarButton(appScreen: AppScreens.shoppingCart, action: {navigationPath.append(AppScreens.shoppingCart)})
                            Group {
                                if isMenuOpen {
                                    MainToolbarButton(systemName: "multiply", description: "Меню", fgColor: .black, bkColor: .clear, action: { isMenuOpen.toggle() })
                                    .font(.system(size: 20, weight: .semibold))
                                }
                                else {
                                    MainToolbarButton(imageName: "Menu", description: "Меню", fgColor: .black, bkColor: .clear, action: { isMenuOpen.toggle() })
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
                .mainToolbarMenu(navigationPath: $navigationPath, isMenuOpen: $isMenuOpen)
            }
            .frame(maxWidth: .infinity, alignment: .top)
            //.mainToolbarMenu(navigationPath: $navigationPath, isMenuOpen: $isMenuOpen)
            .navigationTitle(navigationPath.last?.description ?? "")
            .navigationBarBackButtonHidden(navigationPath.count > 0)
        
    }
}
extension View {
    func mainToolbar(navigationPath: Binding<[AppScreens]>) -> some View {
        modifier(MainToolbarModifier(navigationPath: navigationPath))
    }
}
