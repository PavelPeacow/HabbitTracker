//
//  ChangeHabitVIew.swift
//  HabbitTracker
//
//  Created by Павел Кай on 20.07.2022.
//

import SwiftUI

struct ChangeHabitVIew: View {
    @EnvironmentObject var habitViewModel: HabbitViewModel
    
    let habit: Habit
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var  moc
    
    var body: some View {
        NavigationView {
            
            VStack {
                
                VStack {
                    TextField("Enter name of habbit", text:  $habitViewModel.nameHabbit)
                        .colorStrokeRectangle(color: Color(habitViewModel.color))
                    
                    TextField("Enter description", text: $habitViewModel.decriptionHabbit)
                        .colorStrokeRectangle(color: Color(habitViewModel.color))
                        .onAppear {
                            habitViewModel.nameHabbit = habit.name ?? ""
                            habitViewModel.decriptionHabbit = habit.descr ?? ""
                            habitViewModel.isRemainderOn = habit.isRemainderOn
                            if habitViewModel.isRemainderOn {
                                habitViewModel.remainderDate = habit.remainderDate!
                            }
                            habitViewModel.color = habit.color ?? "Color-1"
                            habitViewModel.frequency = habit.frequency ?? []
                        }
                }
                
                
                VStack {
                    ChooseHabitColorView()
                        .environmentObject(habitViewModel)
                        .colorStrokeRectangle(color: Color(habitViewModel.color))
                    
                    ChooseHabitFrequencyView()
                        .environmentObject(habitViewModel)
                        .colorStrokeRectangle(color: Color(habitViewModel.color))
                }
                
                
                VStack {
                    Toggle(isOn: $habitViewModel.isRemainderOn.animation()) {
                        Text("Do you want get notifications?")
                    }
                    
                    if habitViewModel.isRemainderOn {
                        DatePicker("Pick time", selection: $habitViewModel.remainderDate, displayedComponents: .hourAndMinute)
                        
                    }
                }
                .colorStrokeRectangle(color: Color(habitViewModel.color))
                
                VStack {
                    Button {
                        Task {
                            requestAuthorization()
                            if try await habitViewModel.changeHabit(context: moc, habit: habit) {
                                dismiss()
                            }
                        }
                    } label: {
                        Text("Change habit")
                            .foregroundColor(Color(habitViewModel.color))
                            .colorStrokeRectangle(color: Color(habitViewModel.color))
                    }
                }
            }
            .navigationTitle("Change habbit")
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

struct ChangeHabitVIew_Previews: PreviewProvider {
    
    static let context = DataController().container.viewContext
    static let habbit = Habit(context: context)
    
    static var previews: some View {
        ChangeHabitVIew(habit: habbit)
            .environmentObject(HabbitViewModel())
            .preferredColorScheme(.dark)
    }
}
