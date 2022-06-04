//
//  AddHabbitView.swift
//  HabbitTracker
//
//  Created by Павел Кай on 04.06.2022.
//

import SwiftUI

struct AddHabbitView: View {
    @ObservedObject var habbit: Habbits

    @State private var habbitName = ""
    @State private var habbitDescription = ""
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Enter name of habbit") {
                    TextField("Enter name of habbit", text: $habbitName)
                }
                
                Section("Enter decription") {
                    TextField("Enter description", text: $habbitDescription)
                }
                
                Section {
                    Button {
                        let item = HabbitItem(nameHabbit: habbitName, decriptionHabbit: habbitDescription, streak: 0)
                        habbit.habbits.append(item)
                        dismiss()
                    } label: {
                        Text("Add")
                    }
                }
            }
            .navigationTitle("Add new habbit")
        }
    }
}

struct AddHabbitView_Previews: PreviewProvider {
    static var previews: some View {
        AddHabbitView(habbit: .init())
    }
}
