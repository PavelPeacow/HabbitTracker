//
//  ContentView.swift
//  HabbitTracker
//
//  Created by Павел Кай on 04.06.2022.
//

import SwiftUI


struct ContentView: View {
    
    @EnvironmentObject var habitViewModel: HabbitViewModel
    
    @State private var isSheetActive = false
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var habits: FetchedResults<Habit>
    
    var body: some View {
        NavigationView {
            List {
                CurrentWeekView()
                ForEach(habits) { habitItem in
                    NavigationLink {
                        HabbitDetailView(habit: habitItem)
                    } label: {
                        HabitLabel(habitItem: habitItem)
                    }
                }
                .onDelete { IndexSet in
                    habitViewModel.performDelete(at: IndexSet, context: moc, habitsFetch: habits)
                }
            }
            .listStyle(.plain)
            .toolbar {
                ToolbarItem {
                    Button {
                        isSheetActive.toggle()
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            .sheet(isPresented: $isSheetActive) {
                habitViewModel.resetData()
            } content: {
                AddHabbitView()
                    .environmentObject(habitViewModel)
            }
            .navigationTitle("HabbitTracker")
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

