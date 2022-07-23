//
//  WeekDaysView.swift
//  HabbitTracker
//
//  Created by Павел Кай on 11.07.2022.
//

import SwiftUI

struct HabitWeekDaysView: View {
    @EnvironmentObject var habitViewModel: HabitViewModel
    
    let habitItem: FetchedResults<Habit>.Element
    
    var body: some View {
            HStack(spacing: 0) {
                ForEach(habitViewModel.fetchCurrentWeek().sorted(by: <), id: \.key) { dayNum, dayDate in
                    DayView(habitItem: habitItem, dayDate: dayDate, dayNum: dayNum)
                        .environmentObject(habitViewModel)
                }
            }
            .padding(.horizontal, 5)
    }
}

struct WeekDaysView_Previews: PreviewProvider {
    static let context = DataController().container.viewContext
    static let habbit = Habit(context: context)
    
    static var previews: some View {
        HabitWeekDaysView(habitItem: habbit)
            .preferredColorScheme(.dark)
            .environmentObject(HabitViewModel())
    }
}
