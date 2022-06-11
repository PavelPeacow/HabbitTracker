//
//  AddHabbitView.swift
//  HabbitTracker
//
//  Created by Павел Кай on 04.06.2022.
//

import SwiftUI
import UserNotifications

struct AddHabbitView: View {
    @ObservedObject var habbitsList: Habbits
    
    @State private var habbitName = ""
    @State private var habbitDescription = ""
    
    @State private var selectedColor = ""
    @State private var selectedFrequency = [String]()
    
    @State private var isReminderOn = false
    @State private var selectedDate = Date()
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Enter name of habbit") {
                    TextField("Enter name of habbit", text: $habbitName)
                }
                
                Section("Enter decription") {
                    TextField("Enter description", text: $habbitDescription)
                }
                
                HStack() {
                    ForEach(1...7, id: \.self) { index in
                        let color = "Color-\(index)"
                        Circle()
                            .fill(Color(color))
                            .frame(maxWidth: .infinity)
                            .overlay(content: {
                                if color == selectedColor {
                                    Image(systemName: "checkmark")
                                        .font(.caption.bold())
                                }
                            })
                            .onTapGesture {
                                selectedColor = color
                            }
                    }
                }
                
                Section("frequency") {
                    let weekDays = Calendar.current.weekdaySymbols
                    HStack{
                        ForEach(weekDays, id: \.self) { day in
                            let index = selectedFrequency.firstIndex { value in
                                return value == day
                            } ?? -1
                            Text(day.prefix(2))
                                .foregroundColor(.white)
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background {
                                    Rectangle()
                                        .fill(index != -1 ? Color(selectedColor) : .red.opacity(0.4))
                                }
                                .onTapGesture {
                                    withAnimation {
                                        if index != -1 {
                                            selectedFrequency.remove(at: index)
                                        } else {
                                            selectedFrequency.append(day)
                                        }
                                    }
                                    

                                }
                        }
                    }
                }
                
                Section {
                    Toggle(isOn: $isReminderOn.animation()) {
                        Text("Do you want get notifications?")
                    }
                    
                    if isReminderOn {
                        DatePicker("Pick time", selection: $selectedDate, displayedComponents: .hourAndMinute)
                        
                    }
                }
                
                VStack {
                    Button {
                        let item = HabbitItem(nameHabbit: habbitName, decriptionHabbit: habbitDescription, streak: 0, color: selectedColor, frequency: selectedFrequency)
                        habbitsList.habbits.append(item)
                        dismiss()
                        requestAuthorization()
                        //MARK: Adding notification
                        if  isReminderOn {
                            let content = UNMutableNotificationContent()
                            content.title = "Habit Remainder"
                            content.subtitle = habbitDescription
                            content.sound = .default
                            
                            let calendar = Calendar.current
                            let weekDaySybmols: [String] = calendar.weekdaySymbols
                            
                            for weekDay in selectedFrequency {
                                let id = UUID().uuidString
                                let hour = calendar.component(.hour, from: selectedDate)
                                let minute = calendar.component(.minute, from: selectedDate)
                                let day = weekDaySybmols.firstIndex { currentDay in
                                    return currentDay == weekDay
                                } ?? -1
                                
                                var components = DateComponents()
                                components.hour = hour
                                components.minute = minute
                                components.weekday = day + 1
                                
                                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                                
                                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                                
                                UNUserNotificationCenter.current().add(request)
                                print("Pushing notification")
                            }
                        } else {
                            print("Not Pushing notification")
                        }
                        
                        
                    } label: {
                        Text("Add")
                    }
                }
            }
            .navigationTitle("Add new habbit")
        }
    }
    
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
}

struct AddHabbitView_Previews: PreviewProvider {
    static var previews: some View {
        AddHabbitView(habbitsList: .init())
    }
}
