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
    var orientation : Axis = .vertical
    private var buttonImage : some View {
        return Image(appScreen.imageName)
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
                Group {
                    if orientation == .horizontal {
                        HStack {
                            buttonImage
                            buttonText
                        }
                    }
                    else {
                        VStack {
                            buttonImage
                            buttonText
                        }
                    }
                }
                .padding(.horizontal, 7)
                .padding(.vertical, 5)
                .foregroundStyle(.white)
                .background(RoundedRectangle(cornerRadius: 8).fill(.blue))
            }
            .buttonStyle(.plain)
    }
}
extension View {
    func mainToolbarButton(appScreen : AppScreens,
                           action : @escaping () -> Void,
                           orientation: Axis = Axis.vertical) -> some View {
        modifier(MainToolbarButtonModifier(appScreen : appScreen,
                                           action : action,
                                           orientation: orientation))
    }
}
