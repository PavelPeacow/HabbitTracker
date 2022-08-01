//
//  TabBarView.swift
//  HabbitTracker
//
//  Created by Павел Кай on 23.06.2022.
//

import SwiftUI

struct TabBarView: View {
    
    @StateObject var habitViewModel = HabitViewModel()
    
    var body: some View {
        TabView {
            
            ContentView()
                .tabItem {
                    Image(systemName: "filemenu.and.selection")
                    Text("Habits")
                }
                .environmentObject(habitViewModel)
            
            
            SettingView()
                .tabItem {
                    Image(systemName: "gear.circle")
                    Text("Settings")
                }
                .environmentObject(habitViewModel)
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}
