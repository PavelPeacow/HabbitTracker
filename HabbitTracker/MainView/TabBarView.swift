//
//  TabBarView.swift
//  HabbitTracker
//
//  Created by Павел Кай on 23.06.2022.
//

import SwiftUI

struct TabBarView: View {
    
    @StateObject var habitViewModel = HabbitViewModel()
    
    var body: some View {
        TabView {
            
            ContentView()
                .tabItem {
                    Image(systemName: "filemenu.and.selection")
                    Text("Habits")
                }
                .environmentObject(habitViewModel)
            
//            AddHabbitView()
//                .tabItem {
//                    Image(systemName: "plus.circle")
//                    Text("Add habit")
//                }
//                .environmentObject(habitViewModel)
            
//            StatisticsView()
//                .tabItem {
//                    Image(systemName: "calendar.circle")
//                    Text("Statistics")
//                }
//                .environmentObject(habitViewModel)
            
            AchievementsView()
                .tabItem {
                    Image(systemName: "star.circle")
                    Text("Achievements")
                }
            
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
