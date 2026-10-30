//
//  OrderViewModifier.swift
//  iosApp
//
//  Created by Panferov Stanislav on 19.09.2026.
//

import SwiftUI

struct OrderViewModifier: ViewModifier {
    var orderUIState : OrderUIState
    @Environment(MercuryShopViewModel.self) var viewModel
    let screenWidth : CGFloat = UIScreen.main.bounds.width
    let screenHeight : CGFloat = UIScreen.main.bounds.height
    func body(content: Content) -> some View {
        @Bindable var viewModel : MercuryShopViewModel = viewModel
        viewModel.currentOrder = order
        content
            .overlay(alignment: .center) {
                if viewModel.isOrderOpen {
                    ZStack {
                        Color.black.opacity(0.4)
                            .contentShape(Rectangle())
                            .ignoresSafeArea()
                            .onTapGesture {
                                viewModel.isOrderOpen = false
                            }
                        VStack(alignment: .center, spacing: 10) {
                            HStack(alignment: .center) {
                                IconButton(action: { isOrderListOpen = false }, image: "Closed", width: 15, height: 15, padding: 10, shape: Circle(), backgroundColor: .red)
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            Divider()
                                .frame(maxWidth: .infinity, maxHeight: 2, alignment: .leading)
                            ScrollView {
                                HStack(alignment: .center, spacing: 2) {
                                    Text(orderUIState.creationDate)
                                        .frame(width: screenWidth / 6)
                                    Text(orderUIState.clientName)
                                        .frame(maxWidth: .infinity)
                                    Text(orderUIState.amount)
                                        .frame(width: screenWidth / 6)
                                    Text(orderUIState.status.description)
                                        .frame(width: screenWidth / 6)
                                }
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(.black)
                                .background(.clear)
                                .font(.custom("Arial", size: 12).weight(.regular))
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .scrollIndicators(.automatic, axes: .horizontal)
                            .scrollIndicators(.automatic, axes: .vertical)
                            .background(.clear)
                        }
                        .frame(maxWidth: screenWidth * 0.8, maxHeight: screenHeight * 0.8)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                        .background(RoundedRectangle(cornerRadius: 8).fill(.white))
                        .onTapGesture { }
                        //.safeAreaInset(edge: .top, alignment: .center)
                    }
                }
            }
    }
}
extension View {
    func order(orderUIState : OrderUIState) -> some View {
        modifier(OrderViewModifier(orderUIState: orderUIState))
    }
}
