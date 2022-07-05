//
//  ButtonsTest.swift
//  HabbitTracker
//
//  Created by Павел Кай on 05.07.2022.
//

import SwiftUI

struct CurrentWeekView: View {
    @ObservedObject var habitViewModel = HabbitViewModel()
    
    var body: some View {
        VStack {
            HStack {
                ForEach(habitViewModel.fetchCurrentWeek().sorted(by: <), id: \.key) { dayNum, dayDate in
                    
                    VStack {
                        Text(habitViewModel.extractDate(date: dayDate, format: "dd"))
                            .font(.title2)
                        
                        Text(habitViewModel.extractDate(date: dayDate, format: "EEE"))
                            .font(.callout)
                        
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .background(
                        ZStack() {
                            Capsule()
                                .stroke(lineWidth: 2)
                                .fill(.gray)
                                .opacity(0.5)
                                .frame(width: 40, height: 55)
                            
                            Image(systemName: "circle.circle.fill")
                                .opacity(habitViewModel.isToday(date: dayDate) ? 1 : 0)
                                .foregroundColor(.green)
                                .position(x: 20, y: -15)
                        }
                    )
                }
            }
            .padding(.horizontal, 10)
        }
        .padding(.vertical, 30)
        
    }
}

struct ButtonsTest_Previews: PreviewProvider {
    static var previews: some View {
        CurrentWeekView()
            .preferredColorScheme(.dark)
    }
}
