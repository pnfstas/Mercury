//
//  OrderViewModifier.swift
//  iosApp
//
//  Created by Panferov Stanislav on 10.09.2026.
//

import SwiftUI
import shared

struct OrderView: View {
    @Binding var order : OrderUIState
    var body : some View {
        VStack {
            Text("Корзина")
        }
    }
}
