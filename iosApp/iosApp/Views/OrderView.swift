//
//  OrderViewModifier.swift
//  iosApp
//
//  Created by Panferov Stanislav on 10.09.2026.
//

import SwiftUI
import shared

struct OrderView: View {
    @Environment(MercuryShopViewModel.self) var viewModel
    var body : some View {
        @Bindable var viewModel : MercuryShopViewModel = viewModel
        VStack {
            Text("Корзина")
        }
    }
}
