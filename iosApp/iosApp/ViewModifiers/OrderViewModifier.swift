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
                                        Button(action: { viewModel.saveOrder() }) {
                                            Text("Сохранить")
                                                .multilineTextAlignment(.center)
                                        }
                                        .gridCellColumns(2)
                                        .gridColumnAlignment(.center)
                                        .buttonStyle(.plain)
                                        .frame(width: screenWidthPortion(1 / 3), height: 40)
                                        .padding(.horizontal, 7)
                                        .padding(.vertical, 5)
                                        .foregroundStyle(.white)
                                        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.main)))
                                        //.opacity(viewModel.cartUIStates.isEmpty ? 0.5 : 1)
                                        .font(.custom("Arial", size: 14).weight(.bold))
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
                        .frame(maxWidth: screenWidthPortion(0.8), maxHeight: screenHeightPortion(0.8))
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
