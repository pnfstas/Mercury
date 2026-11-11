//
//  ScreenSizerViewModifier.swift
//  iosApp
//
//  Created by Panferov Stanislav on 10.11.2026.
//

import SwiftUI

struct ScreenSize {
    let width : CGFloat
    let height : CGFloat
    init(width : CGFloat = 0.0, height : CGFloat = 0.0) {
        self.width = width > 0 ? width : UIScreen.main.bounds.width
        self.height = height > 0 ? height : UIScreen.main.bounds.height
    }
    init(_ size: CGSize) {
        self.width = size.width > 0 ? size.width : UIScreen.main.bounds.width
        self.height = size.height > 0 ? size.height : UIScreen.main.bounds.height
    }
}

extension EnvironmentValues {
    @Entry var screenSize : ScreenSize = ScreenSize()
}

struct ScreenSizerViewModifier: ViewModifier {
    @State private var screenSize : ScreenSize = ScreenSize()
    func body(content: Content) -> some View {
        content
            .onGeometryChange(for: CGSize.self) { proxy in
                return proxy.size
            } action : { curScreenSize in
                screenSize = ScreenSize(curScreenSize)
            }
            .environment(\.screenSize, screenSize)
    }
}

extension View {
    func measureScreen() -> some View {
        modifier(ScreenSizerViewModifier())
    }
}
