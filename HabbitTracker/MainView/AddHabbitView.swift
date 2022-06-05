//
//  AddHabbitView.swift
//  HabbitTracker
//
//  Created by Павел Кай on 04.06.2022.
//

import SwiftUI

struct AddHabbitView: View {
    @ObservedObject var habbitsList: Habbits
    
    @State private var habbitName = ""
    @State private var habbitDescription = ""
    
    @State private var selectedColor = ""
    let colors: [Color] = [.red, .yellow, .green, .gray, .orange, .purple, .cyan]
    
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
                
                HStack() {
                    ForEach(1...7, id: \.self) { index in
                        let color = "Color-\(index)"
                        Circle()
                            .fill(Color(color))
                            .frame(width: 30, height: 30)
                            .overlay(content: {
                                if color == selectedColor {
                                    Image(systemName: "checkmark")
                                        .font(.caption.bold())
                                }
                            })
                            .onTapGesture {
                                    selectedColor = color
                            }
                    }
                }

                Section {
                    Button {
                        let item = HabbitItem(nameHabbit: habbitName, decriptionHabbit: habbitDescription, streak: 0, color: selectedColor)
                        habbitsList.habbits.append(item)
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
        AddHabbitView(habbitsList: .init())
    }
}
