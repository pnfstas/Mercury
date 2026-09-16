//
//  IconButton.swift
//  iosApp
//
//  Created by Panferov Stanislav on 13.09.2026.
//

import SwiftUI

struct IconButton<S : Shape> : View {
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
        width : CGFloat = 15.0,
        height : CGFloat = 22.0,
        padding : CGFloat = 4.0,
        shape : S = RoundedRectangle(cornerRadius: 8),
        backgroundColor : Color = .clear
    ) {
        self.action = action
        self.image = image
        self.systemImage = systemImage
        self.width = width
        self.height = height
        self.padding = padding
        self.shape = shape
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        let imageOfButton : Image = systemImage?.isEmpty == false ? Image(systemName: systemImage ?? "") : Image(image ?? "")
        Button(action: action) {
            imageOfButton
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .buttonStyle(.plain)
        .frame(width: width, height: height, alignment: .center)
        .padding(padding)
        .background(shape.fill(backgroundColor))
    }
}
