//
//  MainView.swift
//  iosApp
//
//  Created by Panferov Stanislav on 13.08.2026.
//

import SwiftUI
import shared

struct ProductCard : View {
    @Binding var product : ProductEntity
    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            Image(product.image)
                .resizable()
                .renderingMode(.template)
                .frame(width: 150, height: 150)
                .scaledToFit()
                .background(.clear)
        }
    }
}

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
                            .frame(width: 150, height: 150)
                            .background(.clear)
                        VStack(alignment: .center, spacing: 10) {
                            Text(product.title)
                            Text(product.descr)
                        }
                        Text(product.priceDescr)
                            .frame(width: 150)
                        HStack {
                            Button(action: { product.amountInOrder -= product.portion }) {
                                Text("-")
                                    .frame(width: 22, height: 22)
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 5)
                                    .foregroundStyle(.black)
                                    .background(.clear)
                                    .font(.custom("Arial", size: 16).weight(.bold))
                            }
                            .buttonStyle(.plain)
                            TextField("", value: product.amountInOrder, format: .number)
                                .keyboardType(.decimalPad)
                            Button(action: { product.amountInOrder += product.portion }) {
                                Text("+")
                                    .frame(width: 22, height: 22)
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 5)
                                    .foregroundStyle(.black)
                                    .background(.clear)
                                    .font(.custom("Arial", size: 16).weight(.bold))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}
