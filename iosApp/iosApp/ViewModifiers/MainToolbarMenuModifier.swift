//
//  MainToolbarMenuModifier.swift
//  iosApp
//
//  Created by Panferov Stanislav on 21.08.2026.
//

import SwiftUI

struct MainToolbarMenuModifier : ViewModifier {
    @Binding var navigationPath : [AppScreens]
    @Binding var isMenuOpen : Bool
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottomTrailing) {
                if isMenuOpen {
                    VStack(alignment: .leading, spacing: 5) {
                         MainToolbarMenuButton(navigationPath: $navigationPath, appScreen: AppScreens.about, isMenuOpen: $isMenuOpen)
                         MainToolbarMenuButton(navigationPath: $navigationPath, appScreen: AppScreens.catalog, isMenuOpen: $isMenuOpen)
                         MainToolbarMenuButton(navigationPath: $navigationPath, appScreen: AppScreens.contacts, isMenuOpen: $isMenuOpen)
                         MainToolbarMenuButton(navigationPath: $navigationPath, appScreen: AppScreens.questions, isMenuOpen: $isMenuOpen)
                    }
                    .frame(width: 200)
                    .background(RoundedRectangle(cornerRadius: 15).fill(.menu))
                    .offset(y: 150)
                    //.offset(y: -500)
                    .edgesIgnoringSafeArea(.all)
                }
            }
            .background {
                if isMenuOpen {
                    GeometryReader { proxy in
                        Color.black.opacity(0.001)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                isMenuOpen = false
                            }
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                            .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
                    }
                    .ignoresSafeArea()
                }
            }
    }
}

struct MainToolbarMenuButton : View {
    @Binding var navigationPath : [AppScreens]
    var appScreen : AppScreens
    @Binding var isMenuOpen : Bool
    var body : some View {
        Button(action: {
            isMenuOpen = false
            navigationPath.append(appScreen)
        }) {
            Text(appScreen.description)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .padding(.horizontal, 15)
                .padding(.vertical, 5)
                //.foregroundStyle(.main)
                //.font(.custom("Arial", size: 16).weight(.regular))
                .foregroundStyle(.black)
                .font(.custom("Arial", size: 20).weight(.semibold))
                .background(.menu)
        }
        .buttonStyle(.plain)
    }
}

extension View {
    func mainToolbarMenu(navigationPath : Binding<[AppScreens]>,
                         isMenuOpen : Binding<Bool>) -> some View {
        modifier(MainToolbarMenuModifier(navigationPath: navigationPath,
                                         isMenuOpen: isMenuOpen))
    }
}
