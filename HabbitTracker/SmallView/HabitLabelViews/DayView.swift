//
//  DayView.swift
//  HabbitTracker
//
//  Created by Павел Кай on 05.07.2022.
//

import SwiftUI

struct DayView: View {
    @EnvironmentObject var habitViewModel: HabbitViewModel
    @Environment(\.managedObjectContext) var moc
    
    let habitItem: FetchedResults<Habit>.Element
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

                    .onAppear {
                        if habitViewModel.isDaysAppear(habitToSave: habitItem, dayDate: dayDate) {
                            isOn = true
                        } else {
                            isOn = false
                        }
                    }
            }
            .background(
                Capsule()
                    .opacity(isOn ? 1.0 : 0.1)
                    .foregroundColor(isOn ? Color(habitItem.color ?? "Color-1") : .gray)
                    .onTapGesture {
                        if habitViewModel.showSelectedDays(frequency: habitItem.frequency ?? []).contains(dayNum) && Date.now >= dayDate   {
                            habitViewModel.isTaptedOnDay(indexDay: dayNum, habitItem: habitItem, moc: moc, dayDate: dayDate)
                            withAnimation(.easeInOut(duration: 0.5)) {
                                isOn.toggle()
                            }
                        }
                    }
            )
        }
        .frame(maxWidth: .infinity)
    }
}

struct DayView_Previews: PreviewProvider {
    
    static let context = DataController().container.viewContext
    static let habbit = Habit(context: context)
    
    static var previews: some View {
        DayView(habitItem: habbit, dayDate: Date.now, dayNum: 0)
            .preferredColorScheme(.dark)
            .environmentObject(HabbitViewModel())
    }
}
