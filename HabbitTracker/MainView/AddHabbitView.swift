//
//  AddHabbitView.swift
//  HabbitTracker
//
//  Created by Павел Кай on 04.06.2022.
//

import SwiftUI
import UserNotifications

struct AddHabbitView: View {
    
    @ObservedObject var habitViewModel: HabbitViewModel
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var  moc
    
    var body: some View {
        NavigationView {
            Form {
                Section("Enter name of habbit") {
                    TextField("Enter name of habbit", text:  $habitViewModel.nameHabbit)
                }
                
                Section("Enter decription") {
                    TextField("Enter description", text: $habitViewModel.decriptionHabbit)
                }
                
                HStack() {
                    ForEach(1...7, id: \.self) { index in
                        let color = "Color-\(index)"
                        Circle()
                            .fill(Color(color))
                            .frame(maxWidth: .infinity)
                            .overlay(content: {
                                if color == habitViewModel.color {
                                    Image(systemName: "checkmark")
                                        .font(.caption.bold())
                                }
                            })
                            .onTapGesture {
                                habitViewModel.color = color
                            }
                    }
                }
                
                Section("frequency") {
                    let weekDays = Calendar.current.weekdaySymbols
                    HStack{
                        ForEach(weekDays, id: \.self) { day in
                            let index = habitViewModel.frequency.firstIndex { value in
                                return value == day
                            } ?? -1
                            Text(day.prefix(2))
                                .foregroundColor(.white)
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background {
                                    Rectangle()
                                        .fill(index != -1 ? Color(habitViewModel.color) : .red.opacity(0.4))
                                }
                                .onTapGesture {
                                    withAnimation {
                                        if index != -1 {
                                            habitViewModel.frequency.remove(at: index)
                                        } else {
                                            habitViewModel.frequency .append(day)
                                        }
                                    }
                                    

                                }
                        }
                    }
                }
                
                Section {
                    Toggle(isOn: $habitViewModel.isRemainderOn.animation()) {
                        Text("Do you want get notifications?")
                    }
                    
                    if habitViewModel.isRemainderOn {
                        DatePicker("Pick time", selection: $habitViewModel.remainderDate, displayedComponents: .hourAndMinute)
                        
                    }
                }
                
                VStack {
                    Button {
                        Task {
                            if try await habitViewModel.addHabit(context: moc) {
                                dismiss()
                            }
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
        AddHabbitView(habitViewModel: HabbitViewModel.init())
    }
}
