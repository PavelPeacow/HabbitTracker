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
    
    //EmptyArray of daysComplete that assigned to CoreData attrubute when creating a habit
    @Published var daysCompleteDayAndDate: [Int:String] = [:]
    
    //MARK: Update habit and mark today's date when click on it in ContentView
    func dayComplete(context: NSManagedObjectContext, habitToSave: Habit, indexDay: Int, dayDate: Date) {
        let date = extractDate(date: dayDate, format: "yyyy-MM-dd")
        habitToSave.daysComplete?[indexDay] = date
        habitToSave.streak += 1
        try? context.save()
    }
    
    //MARK: if user tapted on day, check if he already tapted, delete it, or save if doesn't
    func isTaptedOnDay(indexDay: Int, habitItem: Habit, moc: NSManagedObjectContext, dayDate: Date) {
        if isDayAlreadyTapped(context: moc, habitToSave: habitItem, dayIndex: indexDay, dayDate: dayDate) != true {
            if showSelectedDays(frequency: habitItem.frequency ?? []).contains(indexDay) {
                dayComplete(context: moc, habitToSave: habitItem, indexDay: indexDay, dayDate: dayDate)
            }
        }
    }
    
    //MARK: check isDay already tapped: if dictionary contains today Date and dayIndex - delete, else nothing
    func isDayAlreadyTapped(context: NSManagedObjectContext, habitToSave: Habit, dayIndex: Int, dayDate: Date) -> Bool {
        guard habitToSave.daysComplete != nil else {
            return false
        }
        
        if habitToSave.daysComplete!.contains(where: { (key: Int, value: String) in
            (key,value) == (dayIndex,extractDate(date: dayDate, format: "yyyy-MM-dd"))
        }) {
            
            guard let removeDate = habitToSave.daysComplete?.firstIndex(where: { (key: Int, value: String) in
                (key,value) == (dayIndex,extractDate(date: dayDate, format: "yyyy-MM-dd"))
            }) else { return false }
            
            habitToSave.daysComplete?.remove(at: removeDate)
            habitToSave.streak -= 1

            try? context.save()
            return true
        } else {
            return false
        }
    }
    
    //MARK: When ContentView appears, check days that already marked, then color it
    func isDaysAppear(habitToSave: Habit, dayIndex: Int, dayDate: Date) -> Bool {
        guard habitToSave.daysComplete != nil else {
            return false
        }
        
        if habitToSave.daysComplete!.contains(where: { (key: Int, value: String) in
            (key,value) == (dayIndex,extractDate(date: dayDate, format: "yyyy-MM-dd"))
        }) {
            return true
        } else {
            return false
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
        habit.daysComplete = daysCompleteDayAndDate
        
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
            selectedDays.append(day)
        }
        
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
    
    //MARK: Fetch current week from sunday to saturday
    func fetchCurrentWeek() -> [Int:Date] {
        
        let calendar = Calendar.current
        let week = calendar.dateInterval(of: .weekOfMonth, for: Date())
        var currentWeek: [Int:Date] = [:]
        
        
        (0...6).forEach { day in
            if let weekday = calendar.date(byAdding: .day, value: day, to: week!.start) {
                currentWeek[day] = weekday
                print("date - \(weekday)")
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
