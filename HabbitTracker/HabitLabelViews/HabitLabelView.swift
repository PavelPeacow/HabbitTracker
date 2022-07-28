//
//  HabitLabel.swift
//  HabbitTracker
//
//  Created by Павел Кай on 13.06.2022.
//

import SwiftUI

struct HabitLabelView: View {
    let habitItem: Habit
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var habitViewModel = HabitViewModel()
    
    var body: some View {
        VStack {
            HStack {
                
                VStack(alignment: .leading) {
                    Text(habitItem.name ?? "Read")
                }
                
                HStack {
                    Text("\(habitItem.streak)")
                    Image(systemName: "flame")
                    Image(systemName: habitItem.isRemainderOn ? "bell.fill" : "bell.slash.fill")
                }
                .padding(.horizontal, 15)
                
                HStack {
                    Image(systemName: "calendar")
                    Image(systemName: "arrow.right")
                }
                
            }
        }
        .padding()
        .background (
            Capsule()
                .foregroundColor(Color(habitItem.color ?? "Color-1"))
        )
        .padding(.bottom, 40)
    }
}

struct HabitLabelView_Previews: PreviewProvider {
    
    static let context = DataController().container.viewContext
    static let habbit = Habit(context: context)
    
    static var previews: some View {
        HabitLabelView(habitItem: habbit)
            .preferredColorScheme(.dark)
    }
}
