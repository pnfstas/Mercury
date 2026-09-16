//
//  IconButtonStyle.swift
//  iosApp
//
//  Created by Panferov Stanislav on 13.09.2026.
//

import SwiftUI

struct IconButtonStyle : ButtonStyle {
    var action : () -> Void
    var image: String? = nil
    var systemImage : String? = nil
    var width : CGFloat = 15.0
    var height : CGFloat = 22.0
    var padding : CGFloat = 4.0
    func makeBody(configuration: Configuration) -> some View {
        let imageOfButton : Image = systemImage?.isEmpty == false ? Image(systemName: systemImage ?? "") : Image(image ?? "")
        ZStack {
            configuration.label
                .frame(width: 0, height: 0)
                .hidden()
                .onChange(of: configuration.isPressed, initial: false) { isPressed, arg  in
                    if isPressed {
                        action()
                    }
                }
            imageOfButton
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .buttonStyle(.plain)
        .frame(width: width, height: height, alignment: .center)
        .padding(padding)
    }
}
