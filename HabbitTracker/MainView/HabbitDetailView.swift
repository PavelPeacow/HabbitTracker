//
//  HabbitDetailView.swift
//  HabbitTracker
//
//  Created by Павел Кай on 04.06.2022.
//

import SwiftUI

struct HabbitDetailView: View {
    @EnvironmentObject var habitViewModel: HabbitViewModel
    @Environment(\.managedObjectContext) var moc
    
    @State private var isShowingAlert = false
    
    let habit: Habit
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    Text(habit.name ?? "")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Streak: \(habit.streak)")
                        .font(.subheadline)
                    Rectangle()
                        .frame(height: 10)
                        .foregroundColor(Color(habit.color ?? "Color-1"))
                }

                VStack {
                    HStack {
                        ForEach(habit.frequency ?? [""], id: \.self) { day in
                            Text(day)
                        }
                    }
                    Text(habit.descr ?? "")
                        .font(.headline)
                }
                
                Button {
                    isShowingAlert.toggle()
                } label: {
                    Text("Delete habit")
                }
            }
            .alert("Are you shure?", isPresented: $isShowingAlert) {
                Button("Delete", role: .destructive) {
                    habitViewModel.deleteHabit(context: moc, habitItem: habit)
                }
            }
        }
    }
}

struct HabbitDetailView_Previews: PreviewProvider {
    
    static let context = DataController().container.viewContext
    static let habbit = Habit(context: context)
    
    static var previews: some View {
        HabbitDetailView(habit: habbit)
            .environmentObject(HabbitViewModel())
    }
}
