//
//  ChangeHabitVIew.swift
//  HabbitTracker
//
//  Created by Павел Кай on 20.07.2022.
//

import SwiftUI

struct ChangeHabitVIew: View {
    @EnvironmentObject var habitViewModel: HabitViewModel
    
    let habit: Habit
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var  moc
    
    var body: some View {
        NavigationView {
            
            VStack {
                
                VStack {
                    TextField("Enter name of habbit", text:  $habitViewModel.habitName)
                        .colorStrokeRectangle(color: Color(habitViewModel.habitColor))
                    
                    TextField("Enter description", text: $habitViewModel.habitDecription)
                        .colorStrokeRectangle(color: Color(habitViewModel.habitColor))
                }
                
                
                VStack {
                    ChooseHabitColorView()
                        .environmentObject(habitViewModel)
                        .colorStrokeRectangle(color: Color(habitViewModel.habitColor))
                    
                    ChooseHabitFrequencyView()
                        .environmentObject(habitViewModel)
                        .colorStrokeRectangle(color: Color(habitViewModel.habitColor))
                }
                
                
                VStack {
                    Toggle(isOn: $habitViewModel.isRemainderOn.animation()) {
                        Text("Do you want get notifications?")
                    }
                    
                    if habitViewModel.isRemainderOn {
                        DatePicker("Pick time", selection: $habitViewModel.remainderDate, displayedComponents: .hourAndMinute)
                        
                    }
                }
                .colorStrokeRectangle(color: Color(habitViewModel.habitColor))
                
                VStack {
                    Button {
                        Task {
                            if try await habitViewModel.changeHabit(habit: habit, context: moc) {
                                dismiss()
                            }
                        }
                    } label: {
                        Text("Change habit")
                            .foregroundColor(Color(habitViewModel.habitColor))
                            .colorStrokeRectangle(color: Color(habitViewModel.habitColor))
                    }
                }
            }
            .navigationTitle("Change habbit")
            .onAppear {
                habitViewModel.whenChangeHabit(habit: habit)
            }
        }
    }
}

struct ChangeHabitVIew_Previews: PreviewProvider {
    
    static let context = DataController().container.viewContext
    static let habbit = Habit(context: context)
    
    static var previews: some View {
        ChangeHabitVIew(habit: habbit)
            .environmentObject(HabitViewModel())
            .preferredColorScheme(.dark)
    }
}
