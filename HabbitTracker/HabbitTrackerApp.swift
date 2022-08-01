//
//  HabbitTrackerApp.swift
//  HabbitTracker
//
//  Created by Павел Кай on 04.06.2022.
//

import SwiftUI

@main
struct HabbitTrackerApp: App {
    @StateObject private var dataController = DataController()
    @StateObject private var setting = Settings.shared
    
    var body: some Scene {
        WindowGroup {
            TabBarView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .preferredColorScheme(setting.whiteMode ? .light : setting.whiteMode == false ? .dark : nil)
        }
    }
}
