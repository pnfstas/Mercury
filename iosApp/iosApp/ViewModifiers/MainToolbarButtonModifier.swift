//
//  MainToolbarButtonModifier.swift
//  iosApp
//
//  Created by Panferov Stanislav on 18.08.2026.
//

import SwiftUI

struct MainToolbarButtonModifier : ViewModifier {
    var appScreen : AppScreens
    var action : () -> Void
    //var orientation : Axis = .vertical
    private var buttonImage : some View {
        return Image(appScreen.buttonImageName)
            .resizable()
            .renderingMode(.template)
            .frame(width: 22, height: 22)
    }
    private var buttonText : some View {
        return Text(appScreen.description)
            .font(.system(size: 14, weight: .bold))
    }
    func body(content: Content) -> some View {
        content
            Button(action: action) {
                Image(appScreen.buttonImageName)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 22, height: 22)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 5)
                    .foregroundStyle(appScreen.buttonForegroundColor)
                    .background(RoundedRectangle(cornerRadius: 8).fill(appScreen.buttonBackgroundColor))
            }
            .help(appScreen.description)
            .buttonStyle(.plain)
    }
}
extension View {
    func mainToolbarButton(appScreen : AppScreens,
                           action : @escaping () -> Void) -> some View {
        modifier(MainToolbarButtonModifier(appScreen : appScreen,
                                           action : action))
    }
}
