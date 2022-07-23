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
    
    let habitItem: Habit
    let dayDate: Date
    let dayNum: Int
    
    @State private var isOn = false
    
    @State private var isDayLost = false
    
    @State private var isOnFirstWeek1 = false
    
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
                            
                            if habitItem.onFirstWeek {
                                print("wtf")
                                isOnFirstWeek1 = true
                            } else {
                                print("amahasla false")
                                isOnFirstWeek1 = false
                            }
                            
                            if !isOnFirstWeek1 {
                                habitViewModel.dayLostAdd(habit: habitItem, dayDate: dayDate, context: moc)
                                isDayLost = true
                            }
                            
                            
                        } else {
                            isDayLost = false
                            isOn = false
                        }
                        
                        habitViewModel.whenFirstWeekCreate(habit: habitItem, context: moc)
                        
                    }
            }
            .background(
                Capsule()
                    .fill(isOnColor)
                    .opacity(isOnOpacity)
                    .background(
                        
                        isDay
                        
                    )
                
                    .onTapGesture {
                        if !isOnFirstWeek1 {
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
    
    @ViewBuilder
    var isDay: some View {
        if isOnFirstWeek1 {
            firstWeekDay
        } else {
            dayLostCircle
        }
    }
    
    private var dayLostCircle: some View {
        isDayLost
        ? Capsule()
            .foregroundColor(Color(habitItem.color ?? "Color-1"))
            .frame(width: 15, height: 15)
        : nil
    }
    
    private var firstWeekDay: some View {
        Capsule()
            .foregroundColor(.gray)
            .opacity(0.5)
            .frame(width: 15, height: 15)
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
