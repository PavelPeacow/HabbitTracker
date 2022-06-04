//
//  ContentView.swift
//  HabbitTracker
//
//  Created by Павел Кай on 04.06.2022.
//

import SwiftUI


struct ContentView: View {
    @StateObject var habbitsList = Habbits()
    @State private var isSheetActive = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(habbitsList.habbits) { item in
                    NavigationLink {
                        HabbitDetailView(habbit: item, habbitsList: habbitsList)
                    } label: {
                        HStack{
                            Text(item.nameHabbit)
                            Rectangle()
                                .foregroundColor(.green)
                                .frame(width: 5, height: 30)
                            Spacer()

                        }
                        HStack {
                            Text("\(item.streak)")
                        }
                       
                    }
                }
                .onDelete(perform: performDelete)
            }
            .listStyle(.plain)
            .toolbar {
                ToolbarItem {
                    Button {
                        isSheetActive.toggle()
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            .sheet(isPresented: $isSheetActive) {
                AddHabbitView(habbitsList: habbitsList)
            }
            .navigationTitle("HabbitTracker")
        }
    }
    
    func performDelete(at offset: IndexSet) {
        habbitsList.habbits.remove(atOffsets: offset)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
