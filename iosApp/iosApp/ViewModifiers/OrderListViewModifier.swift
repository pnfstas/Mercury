//
//  OrderListViewModifier.swift
//  iosApp
//
//  Created by Panferov Stanislav on 10.09.2026.
//

import SwiftUI
import shared

struct OrderListViewModifier: ViewModifier {
    var viewModel : MercuryShopViewModel
    @Environment(\.screenSize) private var screenSize
    func body(content: Content) -> some View {
        //@Bindable var viewModel : MercuryShopViewModel = mercuryViewModel
        if viewModel.isOrderListOpen {
            content
                .overlay(alignment: .center) {
                    ZStack {
                        Color.black.opacity(0.4)
                            .contentShape(Rectangle())
                            .ignoresSafeArea()
                            .onTapGesture {
                                viewModel.isOrderListOpen = false
                            }
                        VStack(alignment: .center, spacing: 10) {
                            HStack(alignment: .center) {
                                IconButton(action: { viewModel.isOrderListOpen = false }, image: "Closed", width: 15, height: 15, padding: 10, shape: Circle(), backgroundColor: .red)
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            Divider()
                                .frame(maxWidth: .infinity, maxHeight: 2, alignment: .leading)
                            ScrollView {
                                LazyVStack(alignment: .leading, spacing: 7) {
                                    ForEach(viewModel.orderUIStates, id: \.id) { orderUIState in //rawOrderUIState in
                                        //if let orderUIState = rawOrderUIState as? OrderUIState {
                                            HStack(alignment: .center, spacing: 2) {
                                                Text(orderUIState.creationDate.toFormattedString())
                                                    .frame(width: screenSize.width / 6)
                                                Text(orderUIState.clientName)
                                                    .frame(maxWidth: .infinity)
                                                Text(orderUIState.amount.formatted())
                                                    .frame(width: screenSize.width / 6)
                                                Text(orderUIState.status.label)
                                                    .frame(width: screenSize.width / 6)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .foregroundStyle(.black)
                                            .background(.clear)
                                            .font(.custom("Arial", size: 12).weight(.regular))
                                            .highPriorityGesture(
                                                TapGesture(count: 2)
                                                    .onEnded {
                                                        viewModel.currentOrder = orderUIState
                                                    }
                                            )
                                        //} //if
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .scrollIndicators(.automatic, axes: .horizontal)
                            .scrollIndicators(.automatic, axes: .vertical)
                            .background(.clear)
                        }
                        .frame(maxWidth: screenSize.width * 0.8, maxHeight: screenSize.height * 0.8)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                        .background(RoundedRectangle(cornerRadius: 8).fill(.white))
                        .onTapGesture { }
                    }
                }
            }
        else {
            content
        }
    }
}
extension View {
    func orderList(viewModel : MercuryShopViewModel) -> some View {
        modifier(OrderListViewModifier(viewModel : viewModel))
    }
}
