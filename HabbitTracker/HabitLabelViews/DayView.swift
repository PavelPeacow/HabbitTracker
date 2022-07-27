//
//  DayView.swift
//  HabbitTracker
//
//  Created by Павел Кай on 05.07.2022.
//

import SwiftUI

struct DayView: View {
    @EnvironmentObject var habitViewModel: HabitViewModel
    @Environment(\.managedObjectContext) var moc
    
    let habitItem: Habit
    let dayDate: Date
    let dayNum: Int
    
    @State private var isOn = false
    @State private var isDayLost = false
    @State private var isOnFirstWeek = false
    
    var body: some View {
        VStack {
            ZStack() {
                Capsule()
                    .stroke(lineWidth: 2)
                    .fill(tappedColor)
                    .opacity(tappedOpacity)
                    .frame(width: 40, height: 55)
            }
            .background (
                Capsule()
                    .fill(isOnColor)
                    .opacity(isOnOpacity)
                    .background(
                        showCircle
                    )
                
                    .onTapGesture {
                        if !isOnFirstWeek {
                            if whenTap  {
                                
                                habitViewModel.isTaptedOnDay(habitItem: habitItem, dayDate: dayDate, moc: moc)
                                
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    
                                    isOn.toggle()
                                    
                                    if habitViewModel.isToday(date: dayDate) != true {
                                        
                                        isDayLost.toggle()
                                        
                                        if isDayLostContainTodayDate {
                                            habitViewModel.removeFromDayLostArray(habit: habitItem, dayDate: dayDate, context: moc)
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
        .onAppear() {
            if habitViewModel.isDaysAppear(habit: habitItem, dayDate: dayDate) {
                isOn = true
            }
            else if isDayLostAndContained {
                
                if habitItem.onFirstWeek {
                    isOnFirstWeek = true
                } else {
                    isOnFirstWeek = false
                }
                
                if !isOnFirstWeek {
                    habitViewModel.dayLostAdd(habit: habitItem, dayDate: dayDate, context: moc)
                    isDayLost = true
                }
                 
            }
            else {
                isDayLost = false
                isOn = false
            }
            
            if !habitViewModel.showSelectedDays(frequency: habitItem.frequency ?? []).contains(dayNum) {
                isOnFirstWeek = false
            }
            
            //check if new week came, set days to active, if not, to none active
            habitViewModel.whenFirstWeekCreate(habit: habitItem, context: moc)
            
        }
    }
    
    //MARK: Computed properties
    private var whenTap: Bool {
        habitViewModel.showSelectedDays(frequency: habitItem.frequency ?? []).contains(dayNum)
        &&
        Date.now >= dayDate
    }
    
    private var isDayLostContainTodayDate: Bool {
        habitItem.daysLost!.contains(where: { date in
            date == habitViewModel.extractDateToString(date: dayDate, format: "yyyy-MM-dd")
        })
    }
    
    private var isDayLostAndContained: Bool {
        habitViewModel.isDayLost(dayDate: dayDate) && habitViewModel.showSelectedDays(frequency: habitItem.frequency ?? []).contains(dayNum)
    }
    
    //Check statement, and show circle
    @ViewBuilder
    private var showCircle: some View {
        if isOnFirstWeek {
            firstWeekDayCircle
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
    
    private var firstWeekDayCircle: some View {
        Capsule()
            .foregroundColor(.gray)
            .opacity(0.5)
            .frame(width: 15, height: 15)
    }
    
    private var tappedColor: Color {
        habitViewModel.showSelectedDays(frequency: habitItem.frequency ?? []).contains(dayNum)
        ? Color(habitItem.color ?? "Color-1")
        : .gray
    }
    
    private var tappedOpacity: Double {
        habitViewModel.showSelectedDays(frequency: habitItem.frequency ?? []).contains(dayNum)
        ? 1.0
        : 0.5
    }
    
    private var isOnColor: Color {
        isOn
        ? Color(habitItem.color ?? "Color-1")
        : .gray
    }
    
    private var isOnOpacity: Double {
        isOn
        ? 1.0
        : 0.1
    }
        
}

struct DayView_Previews: PreviewProvider {
    
    static let context = DataController().container.viewContext
    static let habbit = Habit(context: context)
    
    static var previews: some View {
        DayView(habitItem: habbit, dayDate: Date.now, dayNum: 0)
            .preferredColorScheme(.dark)
            .environmentObject(HabitViewModel())
    }
}
