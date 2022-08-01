//
//  ContentView.swift
//  HabbitTracker
//
//  Created by Павел Кай on 04.06.2022.
//

import SwiftUI


struct ContentView: View {
    
    @EnvironmentObject var habitViewModel: HabitViewModel
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var habits: FetchedResults<Habit>
    
    var body: some View {
        NavigationView {
            ScrollView(habits.isEmpty ? .init() : .vertical, showsIndicators: false) {
                LazyVStack {
                    
                    CurrentWeekView()
                        .environmentObject(habitViewModel)
                    
                    if habits.isEmpty {
                        AddFirstHabitView()
                            .environmentObject(habitViewModel)
                    }
                    
                    ForEach(habits) { habitItem in
                        
                        HabitWeekDaysView(habitItem: habitItem)
                            .environmentObject(habitViewModel)
                        
                        Divider()
                            .frame(height: 1)
                            .background(Color(habitItem.color ?? "Color-1"))
                            .padding(.horizontal, 5)
                        
                        NavigationLink {
                            StatisticsView(habitItem: habitItem)
                                .environmentObject(habitViewModel)
                        } label: {
                            HabitLabelView(habitItem: habitItem)
                                .environmentObject(habitViewModel)
                        }
                        
                    }
                }
            }
            .tint(.primary)
            .toolbar {
                ToolbarItem {
                    Button {
                        habitViewModel.isShowingAddHabitSheet.toggle()
                    } label: {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.primary)
                    }
                }
            }
            .sheet(isPresented: $habitViewModel.isShowingAddHabitSheet) {
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
            .environmentObject(HabitViewModel())
            .preferredColorScheme(.dark)
    }
}

