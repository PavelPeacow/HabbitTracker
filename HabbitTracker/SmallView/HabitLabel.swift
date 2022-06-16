//
//  HabitLabel.swift
//  HabbitTracker
//
//  Created by Павел Кай on 13.06.2022.
//

import SwiftUI

struct HabitLabel: View {
    @Binding var habitItem: Habit
    
    var fetchCurrentWeek: [Date] {
        
        let calendar = Calendar.current
        let week = calendar.dateInterval(of: .weekOfMonth, for: Date())
        var currentWeek: [Date] = []
        
        
        (1...7).forEach { day in
            if let weekday = calendar.date(byAdding: .day, value: day, to: week!.start) {
                currentWeek.append(weekday)
            }
        }
        
        return currentWeek
    }
    
    func extractDate(date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    
    var body: some View {
        List {
            VStack {
                HStack {
                    ForEach(fetchCurrentWeek, id: \.self) { day in
                        
                        VStack {
                            Text(extractDate(date: day, format: "dd"))
                            
                            Text(extractDate(date: day, format: "EEE"))
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                
                Divider()
                
                HStack {
                    HStack{
                        Circle()
                            .fill(.red)
                            .frame(width: 30, height: 30)
                        Text(habitItem.name!)
                        Spacer()
                    }
                    HStack {
                        Text("\(habitItem.streak)")
                    }
                }
            }
        }
        
    }
}

//struct HabitLabel_Previews: PreviewProvider {
//    static var previews: some View {
//        HabitLabel(habitItem: <#Binding<Habbits>#>)
//    }
//}
