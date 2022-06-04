//
//  ContentView.swift
//  HabbitTracker
//
//  Created by Павел Кай on 04.06.2022.
//

import SwiftUI

struct HabbitItem: Identifiable, Codable {
    var id: UUID
    var nameHabbit: String
    var decriptionHabbit: String
}

class Habbits: ObservableObject {
    @Published var habbit = [HabbitItem]()
}

struct ContentView: View {
    @StateObject var habbit = Habbits()
    @State private var isSheetActive = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(0..<5) { item in
                    NavigationLink {
                        HabbitDetailView(habbit: habbit)
                    } label: {
                        Text("DetailView")
                    }
                }
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        isSheetActive.toggle()
                    } label: {
                        Image(systemName: "circle.fill")
                    }
                }
            }
            .sheet(isPresented: $isSheetActive) {
                AddHabbitView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
