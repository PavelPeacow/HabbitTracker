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
    
    //MARK: Update habit and mark today's date when click on it in ContentView
    func dayComplete(context: NSManagedObjectContext, habitToSave: Habit) {
        habitToSave.habitDaysComplete?.append(extractDate(date: Date.now, format: "yyyy-MM-dd"))
        print(habitToSave.habitDaysComplete ?? "loh")
        habitToSave.streak += 1
        
        try? context.save()
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
    
    func fetchCurrentWeek() -> [Date] {
        
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
    
}
