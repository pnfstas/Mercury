//
//  OrderListViewModifier.swift
//  iosApp
//
//  Created by Panferov Stanislav on 10.09.2026.
//

import SwiftUI

struct OrderListViewModifier: ViewModifier {
    @Binding var navigationPath : [AppScreens]
    func body(content: Content) -> some View {
        content
        VStack {
            Text("Корзина")
        }
    }
}
