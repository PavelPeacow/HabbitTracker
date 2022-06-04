//
//  HabbitDetailView.swift
//  HabbitTracker
//
//  Created by Павел Кай on 04.06.2022.
//

import SwiftUI

struct HabbitDetailView: View {
    @ObservedObject var habbit: Habbits
    
    var body: some View {
        NavigationView {
            Text("Habbit detail view")
        }
    }
}

struct HabbitDetailView_Previews: PreviewProvider {
    static var previews: some View {
        HabbitDetailView(habbit: .init())
    }
}
