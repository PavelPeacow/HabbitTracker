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
    var body: some View {
        VStack {
            Text("Statistic")
            CalendarView()
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .foregroundColor(.orange)
                )
                .frame(height: 260)
            
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
    var calendar = FSCalendar()
    
    func makeUIView(context: Context) -> UIView {
        calendar.backgroundColor = .orange
        return FSCalendar(frame: CGRect(x: 0.0, y: 40.0, width: 200, height: 200))
        
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
}
