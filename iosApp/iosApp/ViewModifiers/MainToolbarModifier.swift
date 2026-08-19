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
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top, spacing: 0) {
                VStack(alignment: .center) {
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
                        HStack(alignment: .center) {
                            EmptyView()
                                .mainToolbarButton(appScreen: AppScreens.catalog, action: {navigationPath.append(AppScreens.catalog)})
                                .mainToolbarButton(appScreen: AppScreens.favorites, action: {navigationPath.append(AppScreens.favorites)})
                                .mainToolbarButton(appScreen: AppScreens.shoppingCart, action: {navigationPath.append(AppScreens.shoppingCart)})
                        }
                        .background(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .background(.white)
                    Image("Mercury")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 88, height: 44)
                    Divider()
                }
            }
            .navigationTitle(navigationPath.last?.description ?? "")
            .navigationBarBackButtonHidden(navigationPath.count > 0)
        
    }
}
extension View {
    func mainToolbar(navigationPath: Binding<[AppScreens]>) -> some View {
        modifier(MainToolbarModifier(navigationPath: navigationPath))
    }
}
