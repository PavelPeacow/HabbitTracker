//
//  DayView.swift
//  HabbitTracker
//
//  Created by Павел Кай on 05.07.2022.
//

import SwiftUI

struct DayView: View {
    let habitItem: FetchedResults<Habit>.Element
    @ObservedObject var habitViewModel: HabbitViewModel
    @Environment(\.managedObjectContext) var moc
    let dayDate: Date
    let dayNum: Int
    
    @State private var isOn = false
    
    var body: some View {
        VStack {
            ZStack() {
                Capsule()
                    .stroke(lineWidth: 2)
                    .fill(habitViewModel.showSelectedDays(frequency: habitItem.frequency ?? []).contains(dayNum) ? Color(habitItem.color ?? "Color-1") : .gray)
                    .opacity(habitViewModel.showSelectedDays(frequency: habitItem.frequency ?? []).contains(dayNum) ? 1.0 : 0.5)
                    .frame(width: 40, height: 55)
                    .onTapGesture {
                        habitViewModel.isTaptedOnDay(indexDay: dayNum, habitItem: habitItem, moc: moc)
                        withAnimation(.easeInOut(duration: 0.5)) {
                            isOn.toggle()
                        }
                        
                    }
            }
            .background(
                Capsule()
                    .opacity(isOn ? 1.0 : 0.0)
                    .foregroundColor(isOn ? Color(habitItem.color ?? "Color-1") : .gray)
            )
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
    }
}

struct DayView_Previews: PreviewProvider {
    
    static let context = DataController().container.viewContext
    static let habbit = Habit(context: context)
    
    static var previews: some View {
        DayView(habitItem: habbit, habitViewModel: HabbitViewModel(), dayDate: Date.now, dayNum: 0)
            .preferredColorScheme(.dark)
    }
}
