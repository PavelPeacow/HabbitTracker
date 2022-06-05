//
//  HabbitDetailView.swift
//  HabbitTracker
//
//  Created by Павел Кай on 04.06.2022.
//

import SwiftUI

struct HabbitDetailView: View {
    var habbit: HabbitItem
    var habbitsList: Habbits
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    Text(habbit.nameHabbit)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Streak: \(habbit.streak)")
                        .font(.subheadline)
                    Rectangle()
                        .frame(height: 10)
                        .foregroundColor(Color(habbit.color))
                }

                Spacer()
                VStack {
                    HStack {
                        ForEach(habbit.frequency, id: \.self) { day in
                            Text(day)
                        }
                    }
                    Text(habbit.decriptionHabbit)
                        .font(.headline)
                }
                
                Spacer()
                Spacer()
                Button {
                    var item = habbit
                    item.streak += 1
                    habbitsList.habbits[habbitsList.habbits.firstIndex(of: habbit)!] = item
                } label: {
                    Text("I've done today's habit")
                }
                Spacer()
                
                Button {
                    var item = habbit
                    item.streak -= 1
                    habbitsList.habbits[habbitsList.habbits.firstIndex(of: habbit)!] = item
                } label: {
                    Text("I've not done today's habit")
                }
                Spacer()
                Spacer()
                
            }
            
           
        }
    }
}

struct HabbitDetailView_Previews: PreviewProvider {
    static var previews: some View {
        HabbitDetailView(habbit: .init(nameHabbit: "Read book", decriptionHabbit: "read books twice a week", streak: 12, color: "Color-3", frequency: ["Sunday", "Sunday", "Sunday",]), habbitsList: .init())
    }
}
