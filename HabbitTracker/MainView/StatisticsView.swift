//
//  StatisticsView.swift
//  HabbitTracker
//
//  Created by Павел Кай on 23.06.2022.
//

import SwiftUI
import UIKit
import FSCalendar

struct StatisticsView: View {
    @State private var selectedDay = Date()
    
    var body: some View {
        VStack {
            Text("Statistic")
            CalendarView(selectedDay: $selectedDay)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .foregroundColor(.orange)
                )
                .frame(height: 260)
            Text("\(selectedDay)")
            Spacer()
            
            VStack {
                HStack {
                    Text("Days in a row 7")
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundColor(.blue)
                        )
                    Text("Habit strong 49%")
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundColor(.blue)
                        )
                }
            }
        }
        
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView()
            .preferredColorScheme(.dark)
    }
}


struct CalendarView: UIViewRepresentable {
    @Binding var selectedDay: Date
    var calendar = FSCalendar()
    
    func updateUIView(_ uiView: FSCalendar, context: Context) {
    }
    

    //MARK: Make UI
    func makeUIView(context: Context) -> FSCalendar {
        calendar.delegate = context.coordinator
        calendar.dataSource = context.coordinator
    
        return calendar
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource {
        var parent: CalendarView

        init(_ parent: CalendarView) {
            self.parent = parent
        }
        
        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            parent.selectedDay = date
        }
        
    }
    

}
