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
    
    @StateObject private var settings = Settings.shared
    
    @FetchRequest(sortDescriptors: []) var habits: FetchedResults<Habit>
    
    var body: some View {
        NavigationView {
            List {
                
                Section("Appearance") {
                    Picker("Pick color mode", selection: settings.$whiteMode) {
                        Text("Dark mode")
                            .tag(false)
                        Text("Light mode")
                            .tag(true)
                    }
                    .pickerStyle(.automatic)
                }
                
                Section("Help") {
                    Text("Terms of use")
                    Text("Privacy Policy")
                    Text("Version 0.9 pre-release")
                }
                
                Section("Warning this will delete all habits without saving!") {
                    Button("Delete all habits") {
                        habitViewModel.deleteAllHabits(habits: habits, context: moc)
                    }
                    .foregroundColor(.red)
                }
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Settings")
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
