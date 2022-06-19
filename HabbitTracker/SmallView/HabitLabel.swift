//
//  HabitLabel.swift
//  HabbitTracker
//
//  Created by Павел Кай on 13.06.2022.
//

import SwiftUI

struct HabitLabel: View {
    let habitItem: FetchedResults<Habit>.Element
    @ObservedObject var habitViewModel = HabbitViewModel()
    
    var fetchCurrentWeek: [Date] {
        
        let calendar = Calendar.current
        let week = calendar.dateInterval(of: .weekOfMonth, for: Date())
        var currentWeek: [Date] = []
        
        
        (0...6).forEach { day in
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
            VStack {
                HStack {
                    ForEach(fetchCurrentWeek, id: \.self) { day in
                        
                        VStack {
                            Text(extractDate(date: day, format: "dd"))
                                .font(.title2)

                            Text(extractDate(date: day, format: "EEE"))
                                .font(.callout)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .background(
                            ZStack() {
                                Capsule()
                                    .fill(habitViewModel.isToday(date: day) ? .black : Color(habitItem.color ?? "Color-1"))
                                    .frame(width: 40, height: 55)
                            }
                        )
                    }
                }
                
                
                
                Divider()
                    .frame(height: 1)
                    .background(Color.orange)

                    
                
                HStack {
                    HStack {
                        Circle()
                            .fill(Color(habitItem.color ?? "Color-1"))
                            .frame(width: 30, height: 30)
                        VStack(alignment: .leading) {
                            Text(habitItem.name ?? "Read")
                            Text(habitItem.descr ?? "Read more books")
                                .font(.caption2)
                        }
                        
                        Spacer()
                    }
                    HStack {
                        Text("\(habitItem.streak)")
                    }
                }
                .padding()
                .background(
                    ZStack {
                        Capsule()
                            .foregroundColor(.brown)
                        
                    }
                )
            }
            .padding(.vertical, 30)
            
    }
}

struct HabitLabel_Previews: PreviewProvider {
    
    static let context = DataController().container.viewContext
    static let habbit = Habit(context: context)
    
    static var previews: some View {
        HabitLabel(habitItem: habbit)
            .preferredColorScheme(.dark)
    }
}
