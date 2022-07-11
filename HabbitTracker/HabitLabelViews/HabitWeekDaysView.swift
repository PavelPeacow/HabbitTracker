//
//  WeekDaysView.swift
//  HabbitTracker
//
//  Created by Павел Кай on 11.07.2022.
//

import SwiftUI

struct HabitWeekDaysView: View {
    let habitItem: FetchedResults<Habit>.Element
    @ObservedObject var habitViewModel = HabbitViewModel()
    
    var body: some View {
            HStack(spacing: 0) {
                ForEach(habitViewModel.fetchCurrentWeek().sorted(by: <), id: \.key) { dayNum, dayDate in
                    DayView(habitItem: habitItem, habitViewModel: habitViewModel, dayDate: dayDate, dayNum: dayNum)
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
    }
}
