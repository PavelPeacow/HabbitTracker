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
                        .colorStrokeRectangle(color: Color(habitViewModel.color))
                    
                    TextField("Enter description", text: $habitViewModel.decriptionHabbit)
                        .colorStrokeRectangle(color: Color(habitViewModel.color))
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
                            if try await habitViewModel.addHabit(context: moc) {
                                dismiss()
                            }
                        }
                    } label: {
                        Text("Add habit")
                            .foregroundColor(Color(habitViewModel.color))
                            .colorStrokeRectangle(color: Color(habitViewModel.color))
                    }
                }
            }
            .navigationTitle("Add new habbit")
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
            .environmentObject(HabbitViewModel())
            .preferredColorScheme(.dark)
    }
}
