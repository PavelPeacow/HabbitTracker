//
//  ChooseHabitFrequencyView.swift
//  HabbitTracker
//
//  Created by Павел Кай on 19.07.2022.
//

import SwiftUI

struct ChooseHabitFrequencyView: View {
    @EnvironmentObject var habitViewModel: HabbitViewModel
    
    var body: some View {
        let weekDays = Calendar.current.weekdaySymbols
        HStack {
            ForEach(weekDays, id: \.self) { day in
                let index = habitViewModel.frequency.firstIndex { value in
                    return value == day
                } ?? -1
                Text(day.prefix(2))
                    .foregroundColor(.white)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background {
                        Capsule()
                            
                            .fill(index != -1 ? Color(habitViewModel.color) : Color(habitViewModel.color).opacity(0.3))
                    }
                    .onTapGesture {
                        withAnimation {
                            if index != -1 {
                                habitViewModel.frequency.remove(at: index)
                            } else {
                                habitViewModel.frequency .append(day)
                            }
                        }
                    }
            }
        }
    }
}

struct ChooseHabitFrequencyView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseHabitFrequencyView()
            .environmentObject(HabbitViewModel())
    }
}
