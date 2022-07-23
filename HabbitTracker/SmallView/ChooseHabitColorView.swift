//
//  ChooseHabitColorView.swift
//  HabbitTracker
//
//  Created by Павел Кай on 19.07.2022.
//

import SwiftUI

struct ChooseHabitColorView: View {
    @EnvironmentObject var habitViewModel: HabitViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(1...7, id: \.self) { index in
                    let color = "Color-\(index)"
                    Circle()
                        .fill(Color(color))
                        .frame(maxWidth: .infinity)
                        .overlay(content: {
                            if color == habitViewModel.habitColor {
                                Image(systemName: "checkmark")
                                    .font(.headline.bold())
                                    .foregroundColor(.black)
                            }
                        })
                        .onTapGesture {
                            withAnimation {
                                habitViewModel.habitColor = color
                            }
                           
                        }
                        .frame(width: 50, height: 45)
                }
            }
        }
    }
}

struct ChooseHabitColorView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseHabitColorView()
            .environmentObject(HabitViewModel())
    }
}
