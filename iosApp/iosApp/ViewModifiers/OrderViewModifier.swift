//
//  OrderViewModifier.swift
//  iosApp
//
//  Created by Panferov Stanislav on 19.09.2026.
//

import SwiftUI
import shared;

struct OrderViewModifier: ViewModifier {
    var viewModel : MercuryShopViewModel
    @Environment(\.screenSize) private var screenSize
    func body(content: Content) -> some View {
        if viewModel.isOrderOpen {
            content
                .overlay(alignment: .center) {
                     ZStack {
                        Color.black.opacity(0.4)
                            .contentShape(Rectangle())
                            .ignoresSafeArea()
                            .onTapGesture {
                                viewModel.currentOrder = nil
                            }
                        VStack(alignment: .center, spacing: 10) {
                            HStack(alignment: .center) {
                                IconButton(action: { viewModel.currentOrder = nil }, image: "Closed", width: 15, height: 15, padding: 10, shape: Circle(), backgroundColor: .red)
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            Divider()
                                .frame(maxWidth: .infinity, maxHeight: 2, alignment: .leading)
                            ScrollView {
                                Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 10) {
                                    GridRow {
                                        Text("Дата создания:")
                                        Text(viewModel.currentOrder?.creationDate.toFormattedString() ?? viewModel.defaultDateStr)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    GridRow {
                                        Text("ФИО заказчика:")
                                        TextField("", text: viewModel.bindOrderClientName())
                                            .textFieldStyle(.roundedBorder)
                                    }
                                    GridRow {
                                        Text("Сумма:")
                                        TextField("", value: viewModel.bindOrderAmount(), format: .number)
                                            .textFieldStyle(.roundedBorder)
                                            .keyboardType(.decimalPad)
                                    }
                                    GridRow {
                                        Text("Статус:")
                                        TextField("", text: viewModel.bindOrderStatus())
                                            .textFieldStyle(.roundedBorder)
                                    }
                                    GridRow {
                                        HStack(alignment: .center, spacing: 20) {
                                            DialogButton(action: { viewModel.saveOrder() }, label: "Сохранить", width: screenSize.width / 3)
                                            DialogButton(action: { viewModel.saveOrder(true) }, label: "Сохранить и закрыть", width: screenSize.width / 3)
                                        }
                                        .gridCellColumns(2)
                                        .frame(maxWidth: .infinity)
                                    }
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
                        .frame(maxWidth: screenSize.width * 0.8, maxHeight: screenSize.height * 0.8)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                        .background(RoundedRectangle(cornerRadius: 8).fill(.white))
                        .onTapGesture { }
                    }
                }
                .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
            }
        else {
            content
        }
    }
}
extension View {
    func order(viewModel : MercuryShopViewModel) -> some View {
        modifier(OrderViewModifier(viewModel : viewModel))
    }
    func screenWidthPortion(_ persent : CGFloat) -> CGFloat {
        let scene : UIWindowScene? = UIApplication.shared.connectedScenes.first as? UIWindowScene
        guard let windowScene = scene else { return 0 }
        guard let window = windowScene.windows.first else { return 0 }
        return window.frame.width * persent
    }
    func screenHeightPortion(_ persent : CGFloat) -> CGFloat {
        let scene : UIWindowScene? = UIApplication.shared.connectedScenes.first as? UIWindowScene
        guard let windowScene = scene else { return 0 }
        guard let window = windowScene.windows.first else { return 0 }
        return window.frame.height * persent
    }
}
