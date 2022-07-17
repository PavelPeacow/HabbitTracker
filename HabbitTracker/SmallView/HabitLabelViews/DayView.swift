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
                    .fill(tappedColor)
                    .opacity(tappedOpacity)
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
                    .fill(isOnColor)
                    .opacity(isOnOpacity)
                
                    .onTapGesture {
                        if whenTap  {
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
    
    private var tappedColor: Color {
        habitViewModel.showSelectedDays(frequency: habitItem.frequency ?? []).contains(dayNum) ? Color(habitItem.color ?? "Color-1") : .gray
    }
    
    private var tappedOpacity: Double {
        habitViewModel.showSelectedDays(frequency: habitItem.frequency ?? []).contains(dayNum) ? 1.0 : 0.5
    }
    
    private var isOnColor: Color {
        isOn ? Color(habitItem.color ?? "Color-1") : .gray
    }
    
    private var isOnOpacity: Double {
        isOn ? 1.0 : 0.1
    }
    
    private var whenTap: Bool {
        habitViewModel.showSelectedDays(frequency: habitItem.frequency ?? []).contains(dayNum) && Date.now == dayDate
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
