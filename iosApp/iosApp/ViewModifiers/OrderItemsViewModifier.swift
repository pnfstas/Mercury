//
//  OrderItemsViewModifier.swift
//  iosApp
//
//  Created by Panferov Stanislav on 19.09.2026.
//
import SwiftUI
import shared

struct OrderItemsViewModifier: ViewModifier {
    var viewModel : MercuryShopViewModel
    @Environment(\.screenSize) private var screenSize
    func body(content: Content) -> some View {
        if let currentOrder = viewModel.currentOrder, viewModel.isOrderItemsOpen {
            content
                .overlay(alignment: .center) {
                    ZStack {
                        Color.black.opacity(0.4)
                            .contentShape(Rectangle())
                            .ignoresSafeArea()
                            .onTapGesture {
                                viewModel.isOrderItemsOpen = false
                            }
                        VStack(alignment: .center, spacing: 10) {
                            HStack(alignment: .center) {
                                IconButton(action: { viewModel.isOrderItemsOpen = false }, image: "Closed", width: 15, height: 15, padding: 10, shape: Circle(), backgroundColor: .red)
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            Divider()
                                .frame(maxWidth: .infinity, maxHeight: 2, alignment: .leading)
                            ScrollView {
                                LazyVStack(alignment: .leading, spacing: 7) {
                                    ForEach(currentOrder.items, id: \.id) { orderItemUIState in
                                        let productId : Int = Int(truncating: NSNumber(value: orderItemUIState.productId))
                                        let element : ProductUIStateTuple? = viewModel.productUIStates.first { $0.productId == productId }
                                        if let product = element?.uiState {
                                            HStack(alignment: .center, spacing: 2) {
                                                AsyncImage(url: URL(string: product.image)) { image in
                                                    image
                                                        .resizable()
                                                        .scaledToFit()
                                                } placeholder: {
                                                    ProgressView()
                                                }
                                                .frame(width: screenSize.width / 8, height: screenSize.width / 8)
                                                VStack(alignment: .center, spacing: 10) {
                                                    Text(product.title)
                                                    Text(product.descr)
                                                }
                                                .frame(maxWidth: .infinity)
                                                Text(product.priceDescr)
                                                    .frame(width: screenSize.width / 8)
                                                HStack(alignment: .center) {
                                                    IconButton(action: { viewModel.decreaseOrderItemQuantity(orderItemUIState) },
                                                               systemImage: "minus")
                                                    TextField("", value: viewModel.bindOrderItemQuantity(orderItemUIState), format: .number)
                                                        .keyboardType(.decimalPad)
                                                        .frame(width: 20, height: 22)
                                                    IconButton(action: { viewModel.increaseOrderItemQuantity(orderItemUIState) },
                                                               systemImage: "plus")
                                                }
                                                .overlay(Rectangle().stroke(.black, lineWidth: 2))
                                            }
                                            .frame(maxWidth: .infinity)
                                            .foregroundStyle(.black)
                                            .background(orderItemUIState.id == viewModel.selectedOrderItem?.id ? Color.cyan : Color.clear)
                                            .font(.custom("Arial", size: 12).weight(.regular))
                                            .highPriorityGesture(
                                                TapGesture(count: 1)
                                                    .onEnded {
                                                        viewModel.updateSelectedOrderItem(orderItemUIState)
                                                    }
                                            )
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .scrollIndicators(.visible, axes: .vertical)
                            .scrollIndicators(.automatic, axes: .horizontal)
                            .background(.clear)
                            .safeAreaInset(edge: .top) {
                                ControlGroup {
                                    DialogButton(action: { viewModel.deleteItemOfCurrentOrder() }, label: "Удалить", width: 100, height: 30, backgroundColor: .clear, foregroundColor: .black, borderColor: .main, borderWidth: 1, opacity: viewModel.deleteItemOfCurrentOrderOpacity)
                                    DialogButton(action: { viewModel.deleteAllItemsOfCurrentOrder() }, label: "Очистить", width: 100, height: 30,
                                        backgroundColor: .clear, foregroundColor: .black, borderColor: .main, borderWidth: 1,
                                        opacity: viewModel.deleteAllItemsOfCurrentOrderOpacity)
                                }
                                .frame(maxWidth: .infinity)
                                .background(.menu)
                                .controlGroupStyle(.navigation)
                            }
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
    func orderItems(viewModel : MercuryShopViewModel) -> some View {
        modifier(OrderItemsViewModifier(viewModel : viewModel))
    }
}

