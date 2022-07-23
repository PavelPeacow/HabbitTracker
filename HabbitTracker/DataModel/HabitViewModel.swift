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
import SwiftUICharts

class HabitViewModel: ObservableObject {
    
    //Habit
    @Published var habitName: String = ""
    @Published var habitDecription: String = ""
    @Published var habitStreak: Int = 0
    @Published var habitColor: String = "Color-1"
    
    //Choosen weekdays
    @Published var habitFrequency: [String] = []
    
    //Remainder
    @Published var isRemainderOn: Bool = false
    @Published var remainderDate = Date()
    
    //CurrentDate
    @Published var currentDay = Date()
    
    //EmptyArray of daysComplete that assigned to CoreData attrubute when creating a habit
    @Published var daysComplete: [String] = []
    @Published var daysLost: [String] = []
    
    //When user create habit, set onFirstWeek - true, when new week appear set onFirstWeek - false
    @Published var onFirstWeek: Bool = false
    
    
    //MARK: when user change habit, habit takes its data to show in ChangeHabitView
    func whenChangeHabit(habit: Habit) {
        habitName = habit.name ?? ""
        habitDecription = habit.descr ?? ""
        isRemainderOn = habit.isRemainderOn
        if isRemainderOn {
            remainderDate = habit.remainderDate!
        }
        habitColor = habit.color ?? "Color-1"
        habitFrequency = habit.frequency ?? []
    }
    

    //MARK: set to none active days that < today day, when new week appear, set days to active
    func whenFirstWeekCreate(habit: Habit, context: NSManagedObjectContext) {
        let todayDate = extractDateToProperForm(date: Date.now)
        let startWeek = (Calendar.current.dateInterval(of: .weekOfMonth, for: Date.now)?.start)!

        if todayDate == startWeek {
            print("amahasla \(startWeek) true 12")
            print("amahasla \(todayDate) true 12")
            habit.onFirstWeek = false
            try? context.save()
        }
          
    }
    
    
    //MARK: change habit
    func changeHabit(habit: Habit, context: NSManagedObjectContext) async throws  -> Bool {
        habit.name = habitName
        habit.descr = habitDecription
        habit.color = habitColor
        habit.frequency = habitFrequency
        habit.isRemainderOn = isRemainderOn
        habit.remainderDate = remainderDate
        habit.onFirstWeek = true
        
        if isRemainderOn {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: habit.notificationsIDs ?? [])
            if let ids = try? await scheduleNotification() {
                habit.notificationsIDs = ids
                if let _ = try? context.save() {
                    return true
                }
            }
        } else {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: habit.notificationsIDs ?? [])
            if let _ = try? context.save() {
                return true
            }
        }
        
        return false
    }
    
    
    //MARK: request notification
    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { authorizarionSuccess, error in
            if let error = error {
                print("Error \(error.localizedDescription)")
            } else {
                print("Authorization request success")
            }
        }
    }
    
    
    //MARK: request notification
    init() {
        requestAuthorization()
    }
    
    
    //MARK: delete all habit
    func deleteAllHabits(habits: FetchedResults<Habit>, context: NSManagedObjectContext) {
        habits.forEach { habit in
            context.delete(habit)
        }
        
        try? context.save()
    }
    
    
    //MARK: if today date > dayDate, dayDate is lost
    func isDayLost(dayDate: Date) -> Bool {
        let calendar = Calendar.current.dateComponents([.year,.month,.day], from: Date())
        let todayDate = Calendar.current.date(from: calendar)!
        if todayDate > dayDate {
            return true
        } else {
            return false
        }
    }
    
    
    //MARK: when user taps on lost day, remove it from dayLost Array
    func removeFromDayLostArray(habit: Habit, dayDate: Date, context: NSManagedObjectContext) {
        let removeDate = habit.daysLost?.firstIndex(where: { date in
            date == extractDateToString(date: dayDate, format: "yyyy-MM-dd")
        })
        
        habit.daysLost?.remove(at: removeDate ?? -1)
        try? context.save()
    }
    
    
    //MARK: if day lost, add it to daysLost array
    func dayLostAdd(habit: Habit, dayDate: Date, context: NSManagedObjectContext) {
        let date = extractDateToString(date: dayDate, format: "yyyy-MM-dd")
        
        if habit.daysLost!.contains(where: { dateDay in
            dateDay == date
        }) != true {
            habit.daysLost?.append(date)
        }
        try? context.save()
    }
    
    
    //MARK: Update habit and add today's date when click on it in ContentView
    func dayComplete(habit: Habit, dayDate: Date, context: NSManagedObjectContext) {
        let date = extractDateToString(date: dayDate, format: "yyyy-MM-dd")
        habit.daysComplete?.append(date)
        habit.streak += 1
        try? context.save()
    }
    
    
    //MARK: if user tapted on day, check if he already tapted, delete it, or save if doesn't
    func isTaptedOnDay(habitItem: Habit, dayDate: Date, moc: NSManagedObjectContext)  {
        if isDayAlreadyTapped(habit: habitItem, dayDate: dayDate, context: moc) != true {
                dayComplete(habit: habitItem, dayDate: dayDate, context: moc)
            }
    }
    
    
    //MARK: check isDay already tapped: if contains today Date - delete
    func isDayAlreadyTapped(habit: Habit, dayDate: Date, context: NSManagedObjectContext) -> Bool {
        guard habit.daysComplete != nil else {
            return false
        }
        
        guard let removeDate = habit.daysComplete?.firstIndex(where: { key in
            key == extractDateToString(date: dayDate, format: "yyyy-MM-dd")
        }) else { return false }
        
        habit.daysComplete?.remove(at: removeDate)
        habit.streak -= 1
        
        try? context.save()
        return true
    }
    
    
    //MARK: When ContentView appears, check days that already marked, then color it
    func isDaysAppear(habit: Habit, dayDate: Date) -> Bool {
        guard habit.daysComplete != nil else {
            return false
        }
        
        if habit.daysComplete!.contains(where: { date in
            date == extractDateToString(date: dayDate, format: "yyyy-MM-dd")
        }) {
            return true
        } else {
            return false
        }
        
    }
    
    
    //MARK: Adding habit when tapping Add button in AddHabbitView
    func addHabit(context: NSManagedObjectContext) async throws  -> Bool {
        let habit = Habit(context: context)
        habit.name = habitName
        habit.descr = habitDecription
        habit.streak = Int16(habitStreak)
        habit.color = habitColor
        habit.frequency = habitFrequency
        habit.id = UUID()
        habit.isRemainderOn = isRemainderOn
        habit.remainderDate = remainderDate
        habit.notificationsIDs = []
        habit.daysComplete = daysComplete
        habit.daysLost = daysLost
        habit.onFirstWeek = true
        
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
        habitName = ""
        habitDecription = ""
        habitStreak = 0
        habitColor = "Color-1"
        habitFrequency = []
        
        isRemainderOn = false
        remainderDate = Date()
    }
    

    //MARK: Delete habit
    func deleteHabit(habit: Habit, context: NSManagedObjectContext) {
        
        context.delete(habit)
        
        if habit.isRemainderOn {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: habit.notificationsIDs ?? [])
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
        content.subtitle = habitDecription
        content.sound = .default
        
        var notificationsIDs: [String] = []
        
        let calendar = Calendar.current
        let weekDaySybmols: [String] = calendar.weekdaySymbols
        
        for weekDay in habitFrequency {
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
    
    
    //MARK: check is is date today
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
            }
        }
        
        return currentWeek
    }
    
    //Extract date to date format yyyy-mm-dd
    func extractDateToProperForm(date: Date) -> Date {
        let calendar = Calendar.current.dateComponents([.year,.month,.day], from: date)
        return Calendar.current.date(from: calendar)!
    }
    
    //Extract data to string
    func extractDateToString(date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    
    //MARK: Get data for chart bar
    func getChartData(daysCompleteCount: Double, daysLostCount: Double) -> [DataPoint] {
        let daysComplete = Legend(color: .green, label: "Days complete", order: 1)
        let daysLost = Legend(color: .red, label: "Days lost", order: 2)
        
        let points: [DataPoint] = [
            .init(value: daysCompleteCount, label: "\(daysCompleteCount.formatted())", legend: daysComplete),
            .init(value: daysLostCount, label: "\(daysLostCount.formatted())", legend: daysLost)
        ]
        
        return points
    }
    
}
