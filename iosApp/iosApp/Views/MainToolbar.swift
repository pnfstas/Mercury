//
//  AppHeaderModifier.swift
//  iosApp
//
//  Created by Panferov Stanislav on 17.08.2026.
//

import SwiftUI

struct MainToolbar : ViewModifier {
    @Binding var navigationPath : NavigationPath
    var navigationTitle : String
    @Environment(\.dismiss) private var dismiss
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top, spacing: 0) {
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
                        Image("Mercury")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 88, height: 44)
                        Button(action: {navigationPath.append(AppScreens.catalog)}) {
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
            .navigationTitle(navigationTitle)
            .navigationBarBackButtonHidden(navigationPath.count > 0)
        
    }
}
extension View {
    func mainToolbar(navigationPath: Binding<NavigationPath>, navigationTitle : String = "") -> some View {
        modifier(MainToolbar(navigationPath: navigationPath, navigationTitle : navigationTitle))
    }
}
