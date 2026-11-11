//
//  MercuryShopViewModel.swift
//  iosApp
//
//  Created by Panferov Stanislav on 03.08.2026.
//
import SwiftUI
import shared

enum AppScreens : Hashable, CaseIterable {
    case main
    case catalog
    case favorites
    case shoppingCart
    case orders
    case about
    case contacts
    case questions
    var description : String {
        return switch self {
        case .main: "Главная"
        case .catalog: "Каталог"
        case .favorites: "Избранное"
        case .shoppingCart: "Корзина"
        case .orders: "Заказы"
        case .about: "Об организации"
        case .contacts: "Контакты"
        case .questions: "Частые вопросы"
        }
    }
    var buttonImageName : String {
        return switch self {
        case .catalog: "Catalog"
        case .favorites: "Favorites"
        case .shoppingCart: "ShoppingCart"
        case .orders: "OrderList"
        default: ""
        }
    }
    var buttonBackgroundColor : Color {
        return switch self {
        case .catalog: .main
        default: .clear
        }
    }
    var buttonForegroundColor : Color {
        return switch self {
        case .catalog: Color.white
        default: Color.black
        }
    }
 }

extension Date {
    private static let defaultDateFormatter : DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        return dateFormatter
    }()
    func toLocalDateTime() -> Kotlinx_datetimeLocalDateTime {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: self)
        let year : Int32 = Int32(components.year ?? 1970)
        let month : Int32 = Int32(components.month ?? 1)
        let day : Int32 = Int32(components.day ?? 1)
        let hour : Int32 = Int32(components.hour ?? 0)
        let minute : Int32 = Int32(components.minute ?? 0)
        let second : Int32 = Int32(components.second ?? 0)
        let nanosecond : Int32 = Int32(components.nanosecond ?? 0)
        return Kotlinx_datetimeLocalDateTime(
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute,
            second: second,
            nanosecond: nanosecond)
    }
    func toString() -> String {
        return Self.defaultDateFormatter.string(from: self)
    }
}
extension Kotlinx_datetimeLocalDateTime {
    func toDate() -> Date {
        let calendar : Calendar = Calendar.current
        let year : Int = Int(self.year)
        let month : Int = Int(self.month.ordinal) + 1
        let day : Int = Int(self.day)
        let hour : Int = Int(self.hour)
        let minute : Int = Int(self.minute)
        let second : Int = Int(self.second)
        let nanosecond : Int = Int(self.nanosecond)
        let components : DateComponents = DateComponents(
            calendar: calendar,
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute,
            second: second,
            nanosecond: nanosecond
        )
        return Calendar.current.date(from: components) ?? Date()
    }
    func toFormattedString() -> String {
        return self.toDate().toString()
    }
}

extension OrderUIState {
    func `with`(
        id : Int32? = nil,
        amount : Float? = nil,
        clientName : String? = nil,
        clientContacts : [ContactType : String]? = nil,
        creationDate : Kotlinx_datetimeLocalDateTime? = nil,
        completionDate : Kotlinx_datetimeLocalDateTime? = nil,
        status : OrderStatus? = nil) -> OrderUIState {
            return self.doCopy(
                id: id ?? self.id,
                amount: amount ?? self.amount,
                clientName: clientName ?? self.clientName,
                clientContacts: clientContacts ?? self.clientContacts,
                creationDate: creationDate ?? self.creationDate,
                completionDate: completionDate ?? self.completionDate,
                status: status ?? self.status)
        }
}

@Observable
final class MercuryShopViewModel {
    let defaultDateStr : String = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        return dateFormatter
    }().string(from: Date())
    private var mercuryShopInteractor : MercuryShopInteractor
    var shopUIStates : [MercuryShopUIState] = []
    var cartUIStates : [MercuryShopUIState] = []
    var orderUIStates : [OrderUIState] = []
    var orderItemUIStates : [OrderItemUIState] = []
    var taskObserveShopUIStates : Task<Void, Never>? = nil
    var taskObserveCartUIStates : Task<Void, Never>? = nil
    var taskObserveOrderUIStates : Task<Void, Never>? = nil
    var taskObserveOrderItemUIStates : Task<Void, Never>? = nil
    var navigationPath : [AppScreens] = []
    var currentScreen : AppScreens = AppScreens.main
    var currentOrder : OrderUIState? = nil
    var currentOrderId : Int = 0
    var isMenuOpen : Bool = false
    var isShoppingCartOpen : Bool = false
    var isOrderListOpen : Bool = false
    var isOrderItemsOpen : Bool = false
    var isOrderOpen : Bool {
        get { return currentOrder != nil }
    }
    init() {
        let koinHelper : KoinHelper = KoinHelper()
        mercuryShopInteractor = koinHelper.getMercuryShopInteractor()
    }
    func observeShopUIStates() {
        taskObserveShopUIStates = Task { @MainActor in
            for await curShopUIStates in mercuryShopInteractor.shopUIStates {
                await MainActor.run {
                    shopUIStates = curShopUIStates
                }
            }
        }
    }
    func observeCartUIStates() {
        taskObserveCartUIStates = Task { @MainActor in
            for await curCartUIStates in mercuryShopInteractor.cartUIStates {
                await MainActor.run {
                    cartUIStates = curCartUIStates
                }
            }
        }
    }
    func observeOrderUIStates() {
        taskObserveOrderUIStates = Task { @MainActor in
            for await curOrderUIStates in mercuryShopInteractor.orderUIStates {
                orderUIStates = curOrderUIStates.compactMap { $0 as? OrderUIState }
            }
        }
    }
    func observeOrderItemUIStates(orderUIState: OrderUIState) {
        taskObserveOrderItemUIStates = Task { @MainActor in
            let stateFlowOrderItemUIStates = mercuryShopInteractor.getOrderItemUIStates(orderUIState: orderUIState)
            for await curOrderItemUIStates in stateFlowOrderItemUIStates {
                await MainActor.run {
                    orderItemUIStates = curOrderItemUIStates
                }
            }
        }
    }
    func increaseEnteredQuantity(shopUIState: MercuryShopUIState) {
        mercuryShopInteractor.stepEnteredQuantity(shopUIState: shopUIState, decrease: false)
    }
    func decreaseEnteredQuantity(shopUIState: MercuryShopUIState) {
        mercuryShopInteractor.stepEnteredQuantity(shopUIState: shopUIState, decrease: true)
    }
    func bindEnteredQuantity(shopUIState: MercuryShopUIState) -> Binding<Float> {
        return Binding(
            get: {
                shopUIState.enteredQuantity
            },
            set: { newValue in
                self.mercuryShopInteractor.updateEnteredQuantity(shopUIState: shopUIState, quantity: newValue)
            }
        )
    }
    func addToShoppingCart(shopUIState : MercuryShopUIState) {
        Task {
            try? await mercuryShopInteractor.addToShoppingCart(shopUIState: shopUIState)
        }
    }
    func increaseShoppingCartQuantity(cartUIState : MercuryShopUIState) {
        Task {
            try? await mercuryShopInteractor.stepShoppingCartQuantity(cartUIState : cartUIState, decrease: false)
        }
    }
    func decreaseShoppingCartQuantity(cartUIState : MercuryShopUIState) {
        Task {
            try? await mercuryShopInteractor.stepShoppingCartQuantity(cartUIState : cartUIState, decrease: true)
        }
    }
    func bindShoppingCartQuantity(cartUIState : MercuryShopUIState) -> Binding<Float> {
        return Binding(
            get: {
                cartUIState.cartQuantity
            },
            set: { newValue in
                self.mercuryShopInteractor.updateEnteredQuantity(shopUIState: cartUIState, quantity: newValue)
            }
        )
    }
    func createOrder() {
        Task {
            if let orderId = try? await mercuryShopInteractor.createOrder() {
                let orderId : Int = Int(truncating: orderId)
                if orderId > 0 {
                    try? await Task.sleep(nanoseconds: 300_000_000)
                    currentOrder = orderUIStates.first { $0.id == orderId }
                }
            }
        }
    }
    func saveOrder() {
        Task {
            try? await mercuryShopInteractor.saveOrder(orderUIState : self.currentOrder)
            currentOrder = nil
        }
    }
    func updateOrderProperty(
        id : Int = 0,
        amount : Float = 0.0,
        clientName : String = "",
        clientContacts : [shared.ContactType : String] = [ : ],
        creationDate : Date = Date(),
        completionDate : Date = Date(),
        status : shared.OrderStatus = .none) {
         Task {
            try? await mercuryShopInteractor.updateOrderProperty(
                id : Int32(id),
                amount : amount,
                clientName : clientName,
                clientContacts : clientContacts,
                creationDate : creationDate.toLocalDateTime(),
                completionDate : completionDate.toLocalDateTime(),
                status : status)
         }
    }
    func bindOrderClientName() -> Binding<String> {
        return Binding(
            get: {
                self.currentOrder?.clientName ?? ""
            },
            set: { newValue in
                self.currentOrder = self.currentOrder?.with(clientName: newValue)
            }
        )
    }
    func bindOrderAmount() -> Binding<Float> {
        return Binding(
            get: {
                self.currentOrder?.amount ?? 0.0
            },
            set: { newValue in
                self.currentOrder = self.currentOrder?.with(amount: newValue)
            }
        )
    }
    func bindOrderStatus() -> Binding<String> {
        return Binding(
            get: {
                self.currentOrder?.status.label ?? ""
            },
            set: { newValue in
                let orderStatus : OrderStatus = OrderStatus.Companion().fromLabel(label: newValue)
                self.currentOrder = self.currentOrder?.with(status: orderStatus)
            }
        )
    }
}
