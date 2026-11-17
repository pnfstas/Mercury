//
//  Catalog.swift
//  iosApp
//
//  Created by Panferov Stanislav on 13.08.2026.
//

import SwiftUI
import shared

struct CatalogView: View {
    var viewModel : MercuryShopViewModel
    @Environment(\.screenSize) private var screenSize
    var body: some View {
        //@Bindable var viewModel : MercuryShopViewModel = mercuryViewModel
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 7) {
                ForEach(viewModel.productUIStates, id: \.key) { key, value in
                    HStack(alignment: .center, spacing: 2) {
                        AsyncImage(url: URL(string: value.product.image)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                            .frame(width: screenSize.width / 8, height: screenSize.width / 8)
                         VStack(alignment: .center, spacing: 10) {
                            Text(value.product.title)
                            Text(value.product.descr)
                        }
                            .frame(maxWidth: .infinity)
                        Text(value.product.priceDescr)
                            .frame(width: screenSize.width / 8)
                        HStack {
                            IconButton(action: { viewModel.decreaseEnteredQuantity(productUIState: value) }, systemImage: "minus")
                            TextField("", value: viewModel.bindEnteredQuantity(productUIState: value), format: .number)
                                .keyboardType(.decimalPad)
                                .frame(width: 20, height: 22)
                            IconButton(action: { viewModel.increaseEnteredQuantity(productUIState: value) }, systemImage: "plus")
                        }
                        .overlay(Rectangle().stroke(.black, lineWidth: 2))
                        Button(action: { viewModel.addToShoppingCart(productUIState: value) }) {
                            Text(value.inStock ? "Добавить в корзину" : "Нет в наличии")
                        }
                        .buttonStyle(.plain)
                        .frame(width: screenSize.width / 4, height: 40)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 5)
                        .foregroundStyle(.white)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.main)))
                        .opacity(value.inStock ? 1 : 0.5)
                        .font(.custom("Arial", size: 14).weight(.bold))
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.black)
                    .background(.clear)
                    .font(.custom("Arial", size: 12).weight(.regular))
                }
            }
        }
        .scrollIndicators(.automatic, axes: .horizontal)
        .scrollIndicators(.automatic, axes: .vertical)
    }
}
