//
//  SettingView.swift
//  HabbitTracker
//
//  Created by Павел Кай on 13.07.2022.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var habitViewModel: HabitViewModel
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(sortDescriptors: []) var habits: FetchedResults<Habit>
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Text("Terms of use")
                }
                
                
                Button("Delete all habits") {
                    habitViewModel.deleteAllHabits(habits: habits, context: moc)
                }
                .foregroundColor(.red)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Settings")
            .padding()
        }
        
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
            .preferredColorScheme(.dark)
            .environmentObject(HabitViewModel())
    }
}
