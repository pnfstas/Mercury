//
//  DialogButton.swift
//  iosApp
//
//  Created by Panferov Stanislav on 10.11.2026.
//

import SwiftUI

struct DialogButton<S : Shape> : View {
    let action : () -> Void
    let image: String?
    let systemImage : String?
    let width : CGFloat
    let height : CGFloat
    let padding : CGFloat
    let shape : S
    let backgroundColor : Color
    init(
        action : @escaping () -> Void,
        image: String? = nil,
        systemImage : String? = nil,
        width : CGFloat = 0,
        height : CGFloat = 22.0,
        padding : CGFloat = 4.0,
        shape : S = RoundedRectangle(cornerRadius: 8),
        backgroundColor : Color = .clear
    ) {
        self.action = action
        self.image = image
        self.systemImage = systemImage
        self.width = width > 0 ? width : 400
        self.height = height
        self.padding = padding
        self.shape = shape
        self.backgroundColor = backgroundColor
    }
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}
