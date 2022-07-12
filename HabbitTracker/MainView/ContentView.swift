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
            ScrollView {
                LazyVStack {
                    CurrentWeekView()
                    ForEach(habits) { habitItem in
                        
                        HabitWeekDaysView(habitItem: habitItem)
                        
                        Divider()
                            .frame(height: 1)
                            .background(Color.orange)
                            .padding(.horizontal, 5)
                        
                        NavigationLink {
                            HabbitDetailView(habit: habitItem)
                        } label: {
                            HabitLabel(habitItem: habitItem)
                        }
                        
                    }
                }
            }
            .tint(.white)
            .toolbar {
                ToolbarItem {
                    Button {
                        isSheetActive.toggle()
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                }
            }
            .sheet(isPresented: $isSheetActive) {
                habitViewModel.resetData()
            } content: {
                AddHabbitView()
                    .environmentObject(habitViewModel)
            }
            .navigationTitle("HabbitTracker")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

