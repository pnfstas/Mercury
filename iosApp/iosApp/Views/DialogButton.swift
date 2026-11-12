//
//  DialogButton.swift
//  iosApp
//
//  Created by Panferov Stanislav on 10.11.2026.
//

import SwiftUI

protocol MarginAndPaddingValues {}

extension CGFloat : MarginAndPaddingValues {}
extension EdgeInsets : MarginAndPaddingValues {}

extension View {
    @ViewBuilder
    func padding(_ value : MarginAndPaddingValues) -> some View {
        switch value {
        case let insets as EdgeInsets:
            self.padding(insets)
        case let length as CGFloat:
            self.padding(length)
        default:
            self.padding(EdgeInsets(top: 5, leading: 7, bottom: 5, trailing: 7))
        }
    }
    @ViewBuilder
    func contentMargins(_ value : MarginAndPaddingValues) -> some View {
        switch value {
        case let insets as EdgeInsets:
            self.contentMargins(.all, insets, for: .automatic)
        case let length as CGFloat:
            self.contentMargins(length, for: .automatic)
        default:
            self
        }
    }
}

struct DialogButton<S : Shape> : View {
    let action : () -> Void
    let label : String?
    let image : String?
    let systemImage : String?
    let width : CGFloat
    let height : CGFloat
    let padding : MarginAndPaddingValues
    let contentMargins : MarginAndPaddingValues
    let alignment : Alignment
    let shape : S
    let backgroundColor : Color
    let foregroundColor : Color
    let opacity : CGFloat
    let font : Font
    private static var defaultPadding : EdgeInsets {
        return EdgeInsets(top: 5, leading: 7, bottom: 5, trailing: 7)
    }
    @Environment(\.screenSize) private var screenSize
    init(
        action : @escaping () -> Void,
        label : String? = nil,
        image : String? = nil,
        systemImage : String? = nil,
        width : CGFloat = 0,
        height : CGFloat = 40.0,
        padding : MarginAndPaddingValues = Self.defaultPadding,
        contentMargins : MarginAndPaddingValues = CGFloat(0),
        alignment : Alignment = .center,
        shape : S = RoundedRectangle(cornerRadius: 8),
        backgroundColor : Color = .main,
        foregroundColor : Color = .white,
        opacity : CGFloat = 1.0,
        font : Font = Font.custom("Arial", size: 14).weight(.bold)
    ) {
        self.action = action
        self.label = label
        self.image = image
        self.systemImage = systemImage
        self.width = width
        self.height = height > 0 ? height : 40
        self.padding = padding
        self.contentMargins = contentMargins
        self.alignment = alignment
        self.shape = shape
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.opacity = opacity
        self.font = font
    }
    var body: some View {
        let buttonWidth : CGFloat = width > 0 ? width : screenSize.width
        let systemName : String? = systemImage.flatMap({ !$0.isEmpty ? $0 : nil })
        let imageName : String? = image.flatMap({ !$0.isEmpty ? $0 : nil })
        let buttonText : String? = label.flatMap({ !$0.isEmpty ? $0 : nil })
        Button(action: action) {
            HStack(alignment: .center, spacing: 10) {
                if let systemName {
                    Image(systemName: systemName)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
                else if let imageName {
                    Image(imageName)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
                if let buttonText {
                    Text(buttonText)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(foregroundColor)
                        .font(font)
                }
            }
        }
        .buttonStyle(.plain)
        .frame(width: buttonWidth, height: height, alignment: alignment)
        .padding(padding)
        .contentMargins(contentMargins)
        .background(shape.fill(backgroundColor))
        .opacity(opacity)
    }
}
