//
//  ContentView.swift
//  HabbitTracker
//
//  Created by Павел Кай on 04.06.2022.
//

import SwiftUI


struct ContentView: View {
    
    @StateObject var habitViewModel = HabbitViewModel()
    
    @State private var isSheetActive = false
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var habits: FetchedResults<Habit>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(habits) { habitItem in
                    NavigationLink {
                        HabbitDetailView(habit: habitItem)
                    } label: {
                        HStack{
                            Circle()
                                .fill(Color(habitItem.color ?? "Color-1"))
                                .frame(width: 50, height: 50)
                            Text(habitItem.name ?? "")
                            Spacer()
                        }
                        HStack {
                            Text("\(habitItem.streak)")
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
                AddHabbitView(habitViewModel: habitViewModel)
            }
            .navigationTitle("HabbitTracker")
        }
    }
    
    func performDelete(at offset: IndexSet) {
//        habbitsList.habbits.remove(atOffsets: offset)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
