//
//  MainView.swift
//  iosApp
//
//  Created by Panferov Stanislav on 13.08.2026.
//

import SwiftUI

struct MainView: View {
    @Binding var navigationPath : [AppScreens]
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            VStack(alignment: .center, spacing: 10) {
                Text("МАГАЗИН\nПРОДУКТОВ ПИТАНИЯ\nЭЛИТНЫХ СОРТОВ\nСЫРА И МЯСА")
                    .foregroundStyle(Color(.main))
                    .font(.custom("Arial", size: 25).weight(.heavy))
                    .lineSpacing(7.5)
                Text("РАБОТАЕМ НЕПОСРЕДСТВЕННО\nС ИНОСТРАННЫМИ ПРОИЗВОДИТЕЛЯМИ")
                    .foregroundStyle(.black)
                    .font(.custom("Arial", size: 14).weight(.regular))
                    .tracking(1.5)
                    .lineSpacing(4)
            }
            .frame(maxWidth: .infinity, alignment: .top)
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color(.bkColorDark)))
            .multilineTextAlignment(.center)
            VStack(alignment: .center, spacing: 15) {
                HStack(alignment: .center, spacing: 20) {
                    VStack{
                        Image("FirstPlaceMedal3d")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .scaledToFit()
                        Text("Гарантия\nкачества")
                    }
                    VStack {
                        Image("Clock3d")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .scaledToFit()
                        Text("10:00 - 19:00")
                    }
                    VStack {
                        Image("ShoppingCart3d")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .scaledToFit()
                        Text("Без ограничений\nпо мин. сумме\nзаказа")
                    }
                }
                //.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .foregroundStyle(Color(.fgColorLight))
                .font(.custom("Arial", size: 16).weight(.bold))
                 Button(action: {navigationPath.append(AppScreens.catalog)}) {
                    HStack(alignment: .center) {
                        Text("Каталог")
                        Image("OpenCatalog")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 20, height: 20)
                            .scaledToFit()
                    }
                    .padding(.horizontal, 35)
                    .padding(.vertical, 15)
                    .foregroundStyle(.white)
                    .font(.custom("Arial", size: 24).weight(.semibold))
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(.main)))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white, lineWidth: 3))
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, alignment: .top)
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color(.bkColorLight)))
            .multilineTextAlignment(.center)
            Spacer()
            VStack {
                Button(action: {}) {
                    HStack {
                        Image("ContactsMenu")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 33, height: 33)
                            .scaledToFit()
                    }
                    .frame(width: 45, height: 45, alignment: .center)
                    .padding(10)
                    .background(Color(.main))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 5))
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(10)
        }
        .padding(16)
        //.frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Image("MainBackground"))
    }
}
