//
//  DayView.swift
//  HabbitTracker
//
//  Created by Павел Кай on 05.07.2022.
//

import SwiftUI

struct DayView: View {
    @EnvironmentObject var habitViewModel: HabbitViewModel
    @Environment(\.managedObjectContext) var moc
    
    let habitItem: FetchedResults<Habit>.Element
    let dayDate: Date
    let dayNum: Int
    
    @State private var isOn = false
    
    @State private var isDayLost = false
    
    var body: some View {
        VStack {
            ZStack() {
                Capsule()
                    .stroke(lineWidth: 2)
                    .fill(tappedColor)
                    .opacity(tappedOpacity)
                    .frame(width: 40, height: 55)
                
                    .onAppear() {
                        if habitViewModel.isDaysAppear(habitToSave: habitItem, dayDate: dayDate) {
                            
                            isOn = true
                            
                        } else if isDayLostAndContained {
                            
                            habitViewModel.dayLostAdd(habit: habitItem, dayDate: dayDate, context: moc)
                            isDayLost = true
                            
                        } else {
                            
                            isOn = false
                        }
                    }
            }
            .background(
                Capsule()
                    .fill(isOnColor)
                    .opacity(isOnOpacity)
                    .background(
                        dayLostCircle
                            .foregroundColor(Color(habitItem.color ?? "Color-1"))
                            .frame(width: 15, height: 15)
                    )
                
                    .onTapGesture {
                        if whenTap  {
                            
                            habitViewModel.isTaptedOnDay(indexDay: dayNum, habitItem: habitItem, moc: moc, dayDate: dayDate)
                            
                            withAnimation(.easeInOut(duration: 0.5)) {
                                
                                isOn.toggle()
                                
                                if habitViewModel.isToday(date: dayDate) != true {
                                    
                                    isDayLost.toggle()
                                    
                                    if isDayLostContainTodayDate {
                                        habitViewModel.removeFromDayLostArray(context: moc, habit: habitItem, dayDate: dayDate)
                                    } else {
                                        habitViewModel.dayLostAdd(habit: habitItem, dayDate: dayDate, context: moc)
                                    }
                                    
                                }
                            }
                        }
                    }
            )
        }
        .frame(maxWidth: .infinity)
    }
    
    private var isDayLostContainTodayDate: Bool {
        habitItem.daysLost!.contains(where: { date in
            date == habitViewModel.extractDate(date: dayDate, format: "yyyy-MM-dd")
        })
    }
    
    private var isDayLostAndContained: Bool {
        habitViewModel.isDayLost(dayDate: dayDate) && habitViewModel.showSelectedDays(frequency: habitItem.frequency ?? []).contains(dayNum)
    }
    
    private var dayLostCircle: some View {
        isDayLost ? Capsule() : nil
    }
    
    private var tappedColor: Color {
        habitViewModel.showSelectedDays(frequency: habitItem.frequency ?? []).contains(dayNum) ? Color(habitItem.color ?? "Color-1") : .gray
    }
    
    private var tappedOpacity: Double {
        habitViewModel.showSelectedDays(frequency: habitItem.frequency ?? []).contains(dayNum) ? 1.0 : 0.5
    }
    
    private var isOnColor: Color {
        isOn ? Color(habitItem.color ?? "Color-1") : .gray
    }
    
    private var isOnOpacity: Double {
        isOn ? 1.0 : 0.1
    }
    
    private var whenTap: Bool {
        habitViewModel.showSelectedDays(frequency: habitItem.frequency ?? []).contains(dayNum) && Date.now >= dayDate
    }
    
}

struct DayView_Previews: PreviewProvider {
    
    static let context = DataController().container.viewContext
    static let habbit = Habit(context: context)
    
    static var previews: some View {
        DayView(habitItem: habbit, dayDate: Date.now, dayNum: 0)
            .preferredColorScheme(.dark)
            .environmentObject(HabbitViewModel())
    }
}
