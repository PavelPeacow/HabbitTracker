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

class HabitViewModel: ObservableObject {
    
    //Habit
    @Published var habitName: String = ""
    @Published var habitStreak: [String] = []
    @Published var habitColor: String = "Color-1"
    
    //Choosen weekdays
    @Published var habitFrequency: [String] = []
    
    //Remainder
    @Published var isRemainderOn: Bool = false
    @Published var remainderDate = Date()
    @Published var remainderText: String = ""
    
    //CurrentDate
    @Published var currentDay = Date()
    
    //EmptyArray of daysComplete that assigned to CoreData attrubute when creating a habit
    @Published var daysComplete: [String] = []
    @Published var daysLost: [String] = []
    
    //When user create habit, set onFirstWeek - true, when new week appear set onFirstWeek - false
    @Published var onFirstWeek: Bool = false
    
    //ContentView
    @Published var isShowingAddHabitSheet = false
    
    //CalendarView
    @Published var isShowingDeleteAlert = false
    @Published var isShowingChangeHabitSheet = false
    
    
    //MARK: request notification
    init() {
        requestAuthorization()
    }
    
    
    //MARK: When user didn't enter in app for a time greater than week, add all lost days in array
    func lostDaysCalendarAdd(habit: Habit, date: Date, context: NSManagedObjectContext) {
        guard habit.frequency != nil else { return }
        guard habit.daysComplete != nil else { return }
        guard habit.daysLost != nil else { return }
        
        
        let stringDate = extractDateToString(date: date, format: "yyyy-MM-dd")
        let formatedDate = extractDateToYYYYMMDDFormat(date: date)
        let todayDate = extractDateToYYYYMMDDFormat(date: Date.now)
        let habitCreateDate = extractDateToYYYYMMDDFormat(date: habit.dateCreated ?? Date.now)
        
        if !habit.daysComplete!.contains(stringDate)
            && !habit.daysLost!.contains(stringDate)
            && habit.frequency!.contains(extractDateToString(date: date, format: "EEEE"))
            && formatedDate < todayDate && formatedDate >= habitCreateDate {
            
            habit.daysLost?.append(stringDate)
            try? context.save()
            
        }
        
    }
    
    
    func daysStreak(habit: Habit, context: NSManagedObjectContext) {
        let sortedHabit = habit.daysComplete?.sorted()
        let lostSort = habit.daysLost?.sorted()
 
        
        guard habit.streak != nil else { return }
                
        for item in sortedHabit! {
            if item > lostSort!.last ?? "" {
                if !habit.streak!.contains(item) {
                    habit.streak?.append(item)
                    try? context.save()
                }
            
            } else {
                habit.streak?.removeAll()
                try? context.save()
            }
            
        }
    }
    
    
    //MARK: validation in textfields
    func isHabitFieldsEmpty() -> Bool {
        if habitName.isEmpty || habitFrequency.isEmpty { return true }
        else { return false }
    }
    
    
    //MARK: tap on days than > dateCreated and than contained in habit frequency
    func isTappedOnRightDays(habit: Habit, date: Date) -> Bool {
        
        let dateCreated = extractDateToYYYYMMDDFormat(date: habit.dateCreated ?? Date.now)
        let calendarDate = extractDateToYYYYMMDDFormat(date: date)
        
        return habit.frequency!.contains(extractDateToString(date: date, format: "EEEE"))
        && dateCreated <= calendarDate
    }
    
    //MARK: the name speaks for itself
    func showCalendarCirclesFromDateCreatedToDateNow(habit: Habit, date: Date) -> Bool {
        
        guard habit.frequency != nil else { return false }
        
        let dateCreated = extractDateToYYYYMMDDFormat(date: habit.dateCreated ?? Date.now)
        let todayDate = extractDateToYYYYMMDDFormat(date: Date.now)
        let calendarDate = extractDateToYYYYMMDDFormat(date: date)
        
        return habit.frequency!.contains(extractDateToString(date: date, format: "EEEE"))
        && dateCreated <= calendarDate
        && todayDate >= calendarDate
    }
    
    
    //MARK: set to none active days that < today day, when new week appear, set days to active
    func whenFirstWeekCreate(habit: Habit, context: NSManagedObjectContext, dayDate: Date) -> Bool {
        let date = extractDateToYYYYMMDDFormat(date: dayDate)
        let dateCreated = extractDateToYYYYMMDDFormat(date: habit.dateCreated ?? Date.now)
        
        if date < dateCreated {
            return true
        } else {
            return false
        }
        
    }
    
    
    //MARK: if today date > dayDate, dayDate is lost
    func isDayLost(dayDate: Date) -> Bool {
        let todayDate = extractDateToYYYYMMDDFormat(date: Date.now)
        
        if todayDate > dayDate { return true }
        else { return false }
    }
    
    
    //MARK: if day lost, add it to daysLost array
    func dayLostAdd(habit: Habit, dayDate: Date, context: NSManagedObjectContext) {
        let date = extractDateToString(date: dayDate, format: "yyyy-MM-dd")
        
        guard habit.daysLost != nil else { return }
        
        if !habit.daysLost!.contains(date) { habit.daysLost?.append(date) }
        
        try? context.save()
    }
    
    
    //MARK: when user taps on lost day, remove it from dayLost Array
    func removeFromDayLostArray(habit: Habit, dayDate: Date, context: NSManagedObjectContext) {
        let date = extractDateToString(date: dayDate, format: "yyyy-MM-dd")
        
        let removeDate = habit.daysLost?.firstIndex(of: date)
        
        habit.daysLost?.remove(at: removeDate ?? -1)
        try? context.save()
    }
    
    
    //MARK: if user tapted on day, check if he already tapted, delete it, or save if doesn't
    func isTaptedOnDay(habitItem: Habit, dayDate: Date, moc: NSManagedObjectContext)  {
        if isDayAlreadyTapped(habit: habitItem, dayDate: dayDate, context: moc) != true {
            dayComplete(habit: habitItem, dayDate: dayDate, context: moc)
        }
    }
    
    
    //MARK: When ContentView appears, check days that already marked, then color it
    func isDaysAppear(habit: Habit, dayDate: Date) -> Bool {
        guard habit.daysComplete != nil else { return false }
        
        let date = extractDateToString(date: dayDate, format: "yyyy-MM-dd")
        
        if habit.daysComplete!.contains(date) { return true }
        else { return false }
        
    }
    
    
    //MARK: Update habit and add today's date when click on it in ContentView
    func dayComplete(habit: Habit, dayDate: Date, context: NSManagedObjectContext) {
        let date = extractDateToString(date: dayDate, format: "yyyy-MM-dd")
        habit.daysComplete?.append(date)
        habit.streak?.append(date)
        try? context.save()
    }
    
    
    //MARK: check isDay already tapped: if contains today Date - delete
    func isDayAlreadyTapped(habit: Habit, dayDate: Date, context: NSManagedObjectContext) -> Bool {
        
        let date = extractDateToString(date: dayDate, format: "yyyy-MM-dd")
        
        guard let removeDate = habit.daysComplete?.firstIndex(of: date) else { return false }
        
        habit.daysComplete?.remove(at: removeDate)
        
        if let remove = habit.streak?.firstIndex(of: date) {
            habit.streak?.remove(at: remove)
        }
       
        
        try? context.save()
        return true
    }
    
    
    //MARK: Adding habit when tapping Add button in AddHabbitView
    func addHabit(context: NSManagedObjectContext) async throws  -> Bool {
        let habit = Habit(context: context)
        habit.name = habitName
        habit.remainderText = remainderText
        habit.streak = habitStreak
        habit.color = habitColor
        habit.frequency = habitFrequency
        habit.id = UUID()
        habit.isRemainderOn = isRemainderOn
        habit.remainderDate = remainderDate
        habit.notificationsIDs = []
        habit.daysComplete = daysComplete
        habit.daysLost = daysLost
        habit.onFirstWeek = true
        habit.dateCreated = currentDay
        
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
    
    
    //MARK: change habit
    func changeHabit(habit: Habit, context: NSManagedObjectContext) async throws  -> Bool {
        habit.name = habitName
        habit.remainderText = remainderText
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
    
    
    //MARK: when user change habit, habit takes its data to show in ChangeHabitView
    func whenChangeHabit(habit: Habit) {
        habitName = habit.name ?? ""
        
        isRemainderOn = habit.isRemainderOn
        if isRemainderOn {
            remainderDate = habit.remainderDate ?? Date.now
            remainderText = habit.remainderText ?? ""
        }
        habitColor = habit.color ?? "Color-1"
        habitFrequency = habit.frequency ?? []
    }
    
    //MARK: Reseting data when dismiss AddHabbitView
    func resetData() {
        habitName = ""
        remainderText = ""
        habitStreak = []
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
    
    //MARK: delete all habit
    func deleteAllHabits(habits: FetchedResults<Habit>, context: NSManagedObjectContext) {
        habits.forEach { habit in
            context.delete(habit)
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
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
        content.subtitle = remainderText
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
    
    //MARK: Extract date to date format yyyy-mm-dd
    func extractDateToYYYYMMDDFormat(date: Date) -> Date {
        let calendar = Calendar.current.dateComponents([.year,.month,.day], from: date)
        return Calendar.current.date(from: calendar)!
    }
    
    //MARK: Extract data to string
    func extractDateToString(date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    //MARK: some sort of kostil
    func reloadView() {
        objectWillChange.send()
    }
    
}
