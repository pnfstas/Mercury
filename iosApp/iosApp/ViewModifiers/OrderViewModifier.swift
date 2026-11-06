//
//  OrderViewModifier.swift
//  iosApp
//
//  Created by Panferov Stanislav on 19.09.2026.
//

import SwiftUI
import shared;

struct OrderViewModifier: ViewModifier {
    //@Environment(MercuryShopViewModel.self) var viewModel
    var mercuryViewModel : MercuryShopViewModel
    let screenWidth : CGFloat = UIScreen.main.bounds.width
    let screenHeight : CGFloat = UIScreen.main.bounds.height
    func body(content: Content) -> some View {
        @Bindable var viewModel : MercuryShopViewModel = mercuryViewModel
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
                                IconButton(action: { viewModel.isOrderListOpen = false }, image: "Closed", width: 15, height: 15, padding: 10, shape: Circle(), backgroundColor: .red)
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            Divider()
                                .frame(maxWidth: .infinity, maxHeight: 2, alignment: .leading)
                            ScrollView {
                                HStack(alignment: .center, spacing: 2) {
                                    Text(viewModel.currentOrder.creationDateStr)
                                        .frame(width: screenWidth / 6)
                                    TextField("ФИО заказчика:", text: viewModel.bindOrderClientName())
                                        .frame(maxWidth: .infinity)
                                    TextField("Сумма:", value: viewModel.bindOrderAmount(), format: .number)
                                        .frame(width: screenWidth / 6)
                                    TextField("Статус:", text: viewModel.bindOrderStatus())
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
                    }
                }
            }
    }
}
extension View {
    func order(mercuryViewModel : MercuryShopViewModel) -> some View {
        modifier(OrderViewModifier(mercuryViewModel : mercuryViewModel))
    }
}
