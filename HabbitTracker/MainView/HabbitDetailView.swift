//
//  HabbitDetailView.swift
//  HabbitTracker
//
//  Created by Павел Кай on 04.06.2022.
//

import SwiftUI

struct HabbitDetailView: View {
    let habit: Habit
    
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    Text(habit.name ?? "")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Streak: \(habit.streak)")
                        .font(.subheadline)
                    Rectangle()
                        .frame(height: 10)
                        .foregroundColor(Color(habit.color ?? "Card-1"))
                }

                Spacer()
                VStack {
                    HStack {
                        ForEach(habit.frequency ?? [""], id: \.self) { day in
                            Text(day)
                        }
                    }
                    Text(habit.descr ?? "")
                        .font(.headline)
                }
                
//                Spacer()
//                Spacer()
//                Button {
//                    var item = habit
//                    item.streak += 1
//                    habbitsList.habbits[habbitsList.habbits.firstIndex(of: habbit)!] = item
//                } label: {
//                    Text("I've done today's habit")
//                }
//                Spacer()
//
//                Button {
//                    var item = habit
//                    item.streak -= 1
//                    habbitsList.habbits[habbitsList.habbits.firstIndex(of: habbit)!] = item
//                } label: {
//                    Text("I've not done today's habit")
//                }
//                Spacer()
//                Spacer()
                
            }
            
           
        }
    }
}

struct HabbitDetailView_Previews: PreviewProvider {
    static var previews: some View {
        HabbitDetailView(habit: Habit.init())
    }
}
