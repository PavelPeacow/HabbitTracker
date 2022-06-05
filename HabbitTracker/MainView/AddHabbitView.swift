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
    @State private var selectedFrequency = [String]()
    
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
                            .frame(maxWidth: .infinity)
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
                
                Section("frequency") {
                    let weekDays = Calendar.current.weekdaySymbols
                    HStack{
                        ForEach(weekDays, id: \.self) { day in
                            let index = selectedFrequency.firstIndex { value in
                                return value == day
                            } ?? -1
                            Text(day.prefix(2))
                                .foregroundColor(.white)
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background {
                                    Rectangle()
                                        .fill(index != -1 ? Color(selectedColor) : .red.opacity(0.4))
                                }
                                .onTapGesture {
                                    withAnimation {
                                        if index != -1 {
                                            selectedFrequency.remove(at: index)
                                        } else {
                                            selectedFrequency.append(day)
                                        }
                                    }
                                    

                                }
                        }
                    }
                }
                
                Section {
                    Button {
                        let item = HabbitItem(nameHabbit: habbitName, decriptionHabbit: habbitDescription, streak: 0, color: selectedColor, frequency: selectedFrequency)
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
