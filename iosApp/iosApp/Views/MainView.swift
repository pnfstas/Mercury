//
//  MainView.swift
//  iosApp
//
//  Created by Panferov Stanislav on 13.08.2026.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        let mainColor : Color = Color(red: 46, green: 90, blue: 59)
        VStack(spacing: 16) {
            VStack {
                Group {
                    Text("МАГАЗИН ПРОДУКТОВ ПИТАНИЯ")
                    Text("ЭЛИТНЫХ СОРТОВ СЫРА И МЯСА")
                }
                .foregroundStyle(mainColor)
                .font(.custom("Arial", size: 45).weight(.heavy))
                Text("РАБОТАЕМ НЕПОСРЕДСТВЕННО С ИНОСТРАННЫМИ ПРОИЗВОДИТЕЛЯМИ")
                    .foregroundStyle(.black)
                    .font(.custom("Arial", size: 18).weight(.regular))
                    .tracking(1.5)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color(red: 232, green: 243, blue: 230, opacity: 0.7)))
            Spacer()
            VStack {
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            Spacer()
            VStack {
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Image("MainBackground"))
    }
}
