//
//  MainToolbarMenuModifier.swift
//  iosApp
//
//  Created by Panferov Stanislav on 21.08.2026.
//

import SwiftUI

struct MainToolbarMenuModifier : ViewModifier {
    var mercuryViewModel : MercuryShopViewModel
    func body(content: Content) -> some View {
        let viewModel : MercuryShopViewModel = mercuryViewModel
        content
            .overlay(alignment: .bottomTrailing) {
                if viewModel.isMenuOpen {
                    VStack(alignment: .leading, spacing: 5) {
                        MainToolbarMenuButton(mercuryViewModel: viewModel, appScreen: AppScreens.about)
                        MainToolbarMenuButton(mercuryViewModel: viewModel, appScreen: AppScreens.catalog)
                        MainToolbarMenuButton(mercuryViewModel: viewModel, appScreen: AppScreens.contacts)
                        MainToolbarMenuButton(mercuryViewModel: viewModel, appScreen: AppScreens.questions)
                    }
                    .frame(width: 200)
                    .background(RoundedRectangle(cornerRadius: 15).fill(.menu))
                    .offset(y: 150)
                    //.offset(y: -500)
                    .edgesIgnoringSafeArea(.all)
                }
            }
            .background {
                if viewModel.isMenuOpen {
                    GeometryReader { proxy in
                        Color.black.opacity(0.001)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.isMenuOpen = false
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
    var mercuryViewModel : MercuryShopViewModel
    var appScreen : AppScreens
    var body : some View {
        @Bindable var viewModel : MercuryShopViewModel = mercuryViewModel
        Button(action: {
            viewModel.isMenuOpen = false
            viewModel.navigationPath.append(appScreen)
        }) {
            Text(viewModel.currentScreen.description)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .padding(.horizontal, 15)
                .padding(.vertical, 5)
                .foregroundStyle(.black)
                .font(.custom("Arial", size: 20).weight(.semibold))
                .background(.menu)
        }
        .buttonStyle(.plain)
    }
}

extension View {
    func mainToolbarMenu(mercuryViewModel : MercuryShopViewModel) -> some View {
        modifier(MainToolbarMenuModifier(mercuryViewModel : mercuryViewModel))
    }
}
