//
//  HabitLabel.swift
//  HabbitTracker
//
//  Created by Павел Кай on 13.06.2022.
//

import SwiftUI

struct HabitLabel: View {
    let habitItem: FetchedResults<Habit>.Element
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var habitViewModel = HabbitViewModel()
    
    var body: some View {
        VStack {
            HStack {
                ForEach(habitViewModel.fetchCurrentWeek().sorted(by: <), id: \.key) { dayNum, dayDate in
                    
                    Button {
                        habitViewModel.isTaptedOnDay(indexDay: dayNum, habitItem: habitItem, moc: moc)
                    } label: {
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
                                    .fill(habitViewModel.showSelectedDays(frequency: habitItem.frequency ?? []).contains(dayNum) ? Color(habitItem.color ?? "Color-1") : .gray)
                                    .opacity(habitViewModel.showSelectedDays(frequency: habitItem.frequency ?? []).contains(dayNum) ? 1.0 : 0.5)
                                    .frame(width: 40, height: 55)
                                
                                Image(systemName: "circle.circle.fill")
                                    .opacity(habitViewModel.isToday(date: dayDate) ? 1 : 0)
                                    .position(x: 20, y: -15)
                            }
                        )
                    } 
                }
            }
            .padding(.horizontal, 10)
            
            Divider()
                .frame(height: 1)
                .background(Color.orange)
            
            VStack {
                HStack {
                    Circle()
                        .fill(Color(habitItem.color ?? "Color-1"))
                        .frame(width: 30, height: 30)
                    
                    VStack(alignment: .leading) {
                        Text(habitItem.name ?? "Read")
                        Text(habitItem.descr ?? "Read more books")
                            .font(.caption2)
                    }
                    
                    HStack{
                        Text("\(habitItem.streak)")
                        Image(systemName: "flame")
                    }
                    .padding(.horizontal, 15)
                    
                    HStack {
                        Image(systemName: "calendar")
                        Image(systemName: "arrow.right")
                    }
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
