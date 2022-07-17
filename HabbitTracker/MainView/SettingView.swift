//
//  SettingView.swift
//  HabbitTracker
//
//  Created by Павел Кай on 13.07.2022.
//

import SwiftUI

struct SettingView: View {
    var body: some View {
        NavigationView {
            List {
                Section {
                    Text("Terms of use")
                }
                
                
                Text("Delete all habits")
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
    }
}
