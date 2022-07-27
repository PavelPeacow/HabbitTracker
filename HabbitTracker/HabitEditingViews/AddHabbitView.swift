//
//  AddHabbitView.swift
//  HabbitTracker
//
//  Created by Павел Кай on 04.06.2022.
//

import SwiftUI
import UserNotifications

struct AddHabbitView: View {
    @EnvironmentObject var habitViewModel: HabitViewModel
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var  moc
    
    var body: some View {
        NavigationView {
            
            ScrollView(showsIndicators: false) {
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
                                if try await habitViewModel.addHabit(context: moc) {
                                    dismiss()
                                }
                            }
                        } label: {
                            Text("Add habit")
                                .foregroundColor(Color(habitViewModel.habitColor))
                                .colorStrokeRectangle(color: Color(habitViewModel.habitColor))
                                .opacity(habitViewModel.isHabitFieldsEmpty() ? 0.5 : 1)
                        }
                    }
                    .disabled (
                        habitViewModel.isHabitFieldsEmpty()
                    )
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "xmark.circle")
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .navigationTitle("Add new habbit")
            }
        }
    }
}

struct ColorStrokeRectangle: ViewModifier {
    let strokeColor: Color
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke()
                    .fill(strokeColor)
            )
            .padding()
    }
}

extension View {
    func colorStrokeRectangle(color: Color) -> some View {
        self.modifier(ColorStrokeRectangle(strokeColor: color))
    }
}

struct AddHabbitView_Previews: PreviewProvider {
    static var previews: some View {
        AddHabbitView()
            .environmentObject(HabitViewModel())
            .preferredColorScheme(.dark)
    }
}
