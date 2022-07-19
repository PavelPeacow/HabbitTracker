//
//  AddHabbitView.swift
//  HabbitTracker
//
//  Created by Павел Кай on 04.06.2022.
//

import SwiftUI
import UserNotifications

struct AddHabbitView: View {
    @EnvironmentObject var habitViewModel: HabbitViewModel
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var  moc
    
    var body: some View {
        NavigationView {
            
            VStack {
                
                VStack {
                    TextField("Enter name of habbit", text:  $habitViewModel.nameHabbit)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke()
                                .fill(Color(habitViewModel.color ))
                        )
                        .padding()
                    
                    TextField("Enter description", text: $habitViewModel.decriptionHabbit)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke()
                                .fill(Color(habitViewModel.color ))
                        )
                        .padding()
                }
                
                VStack {
                    ChooseHabitColorView()
                        .environmentObject(habitViewModel)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke()
                                .fill(Color(habitViewModel.color ))
                        )
                        .padding()
                    
                    ChooseHabitFrequencyView()
                        .environmentObject(habitViewModel)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke()
                                .fill(Color(habitViewModel.color ))
                        )
                        .padding()
                }
                
                
                VStack {
                    Toggle(isOn: $habitViewModel.isRemainderOn.animation()) {
                        Text("Do you want get notifications?")
                    }
                    
                    if habitViewModel.isRemainderOn {
                        DatePicker("Pick time", selection: $habitViewModel.remainderDate, displayedComponents: .hourAndMinute)
                        
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke()
                        .fill(Color(habitViewModel.color ))
                )
                .padding()
                
                VStack {
                    Button {
                        Task {
                            requestAuthorization()
                            if try await habitViewModel.addHabit(context: moc) {
                                dismiss()
                            }
                        }
                    } label: {
                        Text("Add habit")
                            .foregroundColor(Color(habitViewModel.color))
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke()
                                    .fill(Color(habitViewModel.color))
                            )
                            .padding()
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
        AddHabbitView()
            .environmentObject(HabbitViewModel())
            .preferredColorScheme(.dark)
    }
}
