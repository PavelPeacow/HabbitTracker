//
//  ViewModifires.swift
//  HabbitTracker
//
//  Created by Павел Кай on 23.07.2022.
//

import Foundation
import SwiftUI

//MARK: Custom modifiers
struct OrangeRectangle: ViewModifier {
    func body(content: Content) -> some View {
            content
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(.orange)
                        .opacity(0.96)
                        .shadow(color: .orange, radius: 4, x: 0, y: 0)
                )
    }
}

struct ButtonGradient: ViewModifier {
    
    let shadowColor: Color
    let firstGradientColor: Color
    let secondGradientColor: Color
    
    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(gradient: Gradient(colors: [firstGradientColor, secondGradientColor]), startPoint: .trailing, endPoint: .leading)
                    .mask({
                        RoundedRectangle(cornerRadius: 20)
                    })
                    .shadow(color: shadowColor, radius: 8, x: 0, y: 0)
            )
    }
}

struct TextHeadline: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(.black)
    }
}

extension View {
    func orangeRectangle() -> some View {
        self.modifier(OrangeRectangle())
    }
    
    func buttonGradient(shadowColor: Color, firstGradColor: Color, secondGradColor: Color) -> some View {
        self.modifier(ButtonGradient(shadowColor: shadowColor, firstGradientColor: firstGradColor, secondGradientColor: secondGradColor))
    }
    
    func textHeadline() -> some View {
        self.modifier(TextHeadline())
    }
}
