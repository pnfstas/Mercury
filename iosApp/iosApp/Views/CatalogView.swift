//
//  Catalog.swift
//  iosApp
//
//  Created by Panferov Stanislav on 13.08.2026.
//

import SwiftUI
import shared

struct CatalogView: View {
    @Binding var productsViewModel : ProductsViewModel
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 7) {
                ForEach(productsViewModel.products, id: \.id) { product in
                    HStack(alignment: .center, spacing: 5) {
                        AsyncImage(url: URL(string: product.image)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                            .frame(width: 100, height: 100)
                            .background(.clear)
                        VStack(alignment: .center, spacing: 10) {
                            Text(product.title)
                            Text(product.descr)
                        }
                        Text(product.priceDescr)
                            .frame(width: 150)
                        HStack {
                            Button(action: { productsViewModel.decreaseAmountInOrder(product: product) }) {
                                Text("-")
                                    .frame(width: 22, height: 22)
                                    //.padding(.horizontal, 7)
                                    //.padding(.vertical, 5)
                                    .foregroundStyle(.black)
                                    .background(.clear)
                                    .font(.custom("Arial", size: 16).weight(.bold))
                            }
                            .buttonStyle(.plain)
                            TextField("", value: productsViewModel.bindAmountInOrder(product: product), format: .number)
                                .keyboardType(.decimalPad)
                                .frame(width: 22, height: 22)
                            Button(action: { productsViewModel.increaseAmountInOrder(product: product) }) {
                                Text("+")
                                    .frame(width: 22, height: 22)
                                    //.padding(.horizontal, 7)
                                    //.padding(.vertical, 5)
                                    .foregroundStyle(.black)
                                    .background(.clear)
                                    .font(.custom("Arial", size: 16).weight(.bold))
                            }
                            .buttonStyle(.plain)
                            Button(action: { productsViewModel.increaseAmountInOrder(product: product) }) {
                                Text(product.inStock ? "Добавить в корзину" : "Нет в наличии")
                            }
                            .buttonStyle(.plain)
                            .frame(width: 50, height: 22)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 5)
                            .foregroundStyle(.white)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color(.main)))
                            .opacity(product.inStock ? 1 : 0.5)
                            .font(.custom("Arial", size: 16).weight(.bold))
                        }
                        .overlay(Rectangle().stroke(.black, lineWidth: 2))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .scrollIndicators(.automatic, axes: .horizontal)
        .scrollIndicators(.automatic, axes: .vertical)
    }
}
