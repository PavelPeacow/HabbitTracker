//
//  HabbitClass.swift
//  HabbitTracker
//
//  Created by Павел Кай on 04.06.2022.
//

import Foundation
import CoreData
import NotificationCenter
import SwiftUI

class HabbitViewModel: ObservableObject {
    
    //Habit
    @Published var nameHabbit: String = ""
    @Published var decriptionHabbit: String = ""
    @Published var streak: Int = 0
    @Published var color: String = "Card-1"
    
    //Choosen weekdays
    @Published var frequency: [String] = []
    
    //Remainder
    @Published var isRemainderOn: Bool = false
    @Published var remainderDate = Date()
    
    //CurrentDate
    @Published var currentDay = Date()
    
    //EmptyArray of daysComplete
    @Published var daysComplete: [String] = []
    
    @Published var daysCompleteDick: [Int:String] = [:]
    
    //MARK: Update habit and mark today's date when click on it in ContentView
//    func dayComplete(context: NSManagedObjectContext, habitToSave: Habit) {
//        habitToSave.habitDaysComplete?.append(extractDate(date: Date.now, format: "yyyy-MM-dd"))
//        print(habitToSave.habitDaysComplete ?? "loh")
//        habitToSave.streak += 1
//
//        try? context.save()
//    }
    
    //MARK: Update habit and mark today's date when click on it in ContentView
    func dayComplete(context: NSManagedObjectContext, habitToSave: Habit, indexDay: Int) {
        let date = extractDate(date: Date.now, format: "yyyy-MM-dd")
        habitToSave.dictionaryDateDay?[indexDay] = date
        print(habitToSave.dictionaryDateDay ?? "dick empty")
        habitToSave.streak += 1
        try? context.save()
    }
    
    func isTaptedOnDay(indexDay: Int, habitItem: Habit, moc: NSManagedObjectContext) {
        if showSelectedDays(frequency: habitItem.frequency ?? []).contains(indexDay) {
            dayComplete(context: moc, habitToSave: habitItem, indexDay: indexDay)
        }
    }
    
//    func isDayAlreadyTapped(context: NSManagedObjectContext, habitToSave: Habit) -> Bool {
//        if habitToSave.habitDaysComplete!.contains(where: { date in
//            date == extractDate(date: Date.now, format: "yyyy-MM-dd")
//        }) {
//            let removeDate = habitToSave.habitDaysComplete?.firstIndex(where: { date in
//                date == extractDate(date: Date.now, format: "yyyy-MM-dd")
//            }) ?? -1
//            habitToSave.habitDaysComplete?.remove(at: removeDate)
//            habitToSave.streak -= 1
//            print("dadadaadad")
//            try? context.save()
//            return true
//        } else {
//            return false
//        }
//
//    }
    
    func whenDaysAppear(habitToSave: Habit, dayIndex: Int) -> Bool {
        
        var isContains = false
        
        guard habitToSave.dictionaryDateDay == nil else {
            if (habitToSave.dictionaryDateDay!.contains(where: { (key: Int, value: String) in
                (key,value) == (dayIndex,extractDate(date: Date.now, format: "yyyy-MM-dd"))
            })) {
                isContains = true
            } else {
                isContains = false
            }
            return isContains
        }
        return isContains
        
    }
    
    //MARK: check isDay already tapped: if dictionary contains today Date and dayIndex - delete, else nothing
    func isDayAlreadyTapped(context: NSManagedObjectContext, habitToSave: Habit, dayIndex: Int) -> Bool {
        if ((habitToSave.dictionaryDateDay?.contains(where: { (key: Int, value: String) in
            (key,value) == (dayIndex,extractDate(date: Date.now, format: "yyyy-MM-dd"))
        })) != nil) {
            guard let removeDate = (habitToSave.dictionaryDateDay?.firstIndex(where: { (key: Int, value: String) in
                (key,value) == (dayIndex,extractDate(date: Date.now, format: "yyyy-MM-dd"))
            })) else { return false }
            habitToSave.dictionaryDateDay?.remove(at: removeDate)
            habitToSave.streak -= 1
            print("dadadaadad")
            try? context.save()
            return true
        } else {
            return false
        }
            
    }
    
    func checkSaveOrNotToSave(dayNum: Int, habitItem: Habit, moc: NSManagedObjectContext) {
        if isDayAlreadyTapped(context: moc, habitToSave: habitItem, dayIndex: dayNum) != true {
            isTaptedOnDay(indexDay: dayNum, habitItem: habitItem, moc: moc)
        } 
    }
    
    //MARK: Adding habit when tapping Add button in AddHabbitView
    func addHabit(context: NSManagedObjectContext) async throws  -> Bool {
        let habit = Habit(context: context)
        habit.name = nameHabbit
        habit.descr = decriptionHabbit
        habit.streak = Int16(streak)
        habit.color = color
        habit.frequency = frequency
        habit.id = UUID()
        habit.isRemainderOn = isRemainderOn
        habit.remainderDate = remainderDate
        habit.notificationsIDs = []
        habit.habitDaysComplete = daysComplete
        habit.dictionaryDateDay = daysCompleteDick
        
        if isRemainderOn {
            if let ids = try? await scheduleNotification() {
                habit.notificationsIDs = ids
                if let _ = try? context.save() {
                    return true
                }
            }
        } else {
            if let _ = try? context.save() {
                return true
            }
            
        }
        
        return false
    }
    
    //MARK: Reseting data when dismiss AddHabbitView
    func resetData() {
        nameHabbit = ""
        decriptionHabbit = ""
        streak = 0
        color = "Card-1"
        frequency = []
        
        isRemainderOn = false
        remainderDate = Date()
    }
    
    //MARK: Deleting from list
    func performDelete(at offsets: IndexSet, context: NSManagedObjectContext, habitsFetch: FetchedResults<Habit>) {
            for index in offsets {
                let habit = habitsFetch[index]
                context.delete(habit)
                
                if habit.isRemainderOn {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: habit.notificationsIDs ?? [])
                }
            }
            
            try? context.save()
    }
    
    //MARK: Show selectedDays in HabitLabel's weekView
    func showSelectedDays(frequency: [String]) -> [Int] {
        let calendar = Calendar.current
        let weekDaySybmols: [String] = calendar.weekdaySymbols
        var selectedDays: [Int] = []
        
        for weekDay in frequency {
            let day = weekDaySybmols.firstIndex { currentDay in
                return currentDay == weekDay
            } ?? -1
            print(day)
            selectedDays.append(day)
        }
        print(selectedDays)
        return selectedDays
    }
        
    //MARK: Scheduling notifications
    func scheduleNotification() async throws -> [String] {
        let content = UNMutableNotificationContent()
        content.title = "Habit Remainder"
        content.subtitle = decriptionHabbit
        content.sound = .default
        
        var notificationsIDs: [String] = []
        
        let calendar = Calendar.current
        let weekDaySybmols: [String] = calendar.weekdaySymbols
        
        for weekDay in frequency {
            let id = UUID().uuidString
            let hour = calendar.component(.hour, from: remainderDate)
            let minute = calendar.component(.minute, from: remainderDate)
            let day = weekDaySybmols.firstIndex { currentDay in
                return currentDay == weekDay
            } ?? -1
            
            var components = DateComponents()
            components.hour = hour
            components.minute = minute
            components.weekday = day + 1
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            
            try await UNUserNotificationCenter.current().add(request)
            
            notificationsIDs.append(id)
            
        }
        
        return notificationsIDs
    }
    
    //MARK: Date HabbitLabel
    func isToday(date: Date) -> Bool {
        let calendar = Calendar.current
        
        return calendar.isDate(currentDay, inSameDayAs: date)
    }
    
    func fetchCurrentWeek() -> [Int:Date] {
        
        let calendar = Calendar.current
        let week = calendar.dateInterval(of: .weekOfMonth, for: Date())
        var currentWeek: [Int:Date] = [:]
        
        
        (0...6).forEach { day in
            if let weekday = calendar.date(byAdding: .day, value: day, to: week!.start) {
                currentWeek[day] = weekday
            }
        }
        
        return currentWeek
    }
    
    func extractDate(date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
        
}
