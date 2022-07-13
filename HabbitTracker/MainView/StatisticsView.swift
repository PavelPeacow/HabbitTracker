//
//  StatisticsView.swift
//  HabbitTracker
//
//  Created by Павел Кай on 23.06.2022.
//

import SwiftUI
import UIKit
import FSCalendar
import SwiftUICharts

struct StatisticsView: View {
    @EnvironmentObject var habitViewModel: HabbitViewModel
    @FetchRequest(sortDescriptors: []) var habits: FetchedResults<Habit>
    
    private var daysCompleteCount: Double {
        var completeDays = 0.0
        for i in habits {
            completeDays += Double(i.daysComplete?.count ?? 0)
        }
        
        return completeDays
    }
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Statistic")
                CalendarView(habits: habits)
                    .environmentObject(habitViewModel)
                    .orangeRectangle()
                    .frame(height: 260)
                    .padding()
                
                Spacer()
                
                HStack {
                    HorizontalBarChartView(dataPoints: habitViewModel.getChartData(daysCompleteCount: daysCompleteCount))
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .orangeRectangle()
                        .fixedSize()
                }
                .padding()
                
                VStack {
                    HStack {
                        Text("Days in a row 7")
                            .font(.headline)
                            .foregroundColor(.black)
                        Image(systemName: "flame")
                            .foregroundColor(.black)
                    }
                    .padding()
                    .orangeRectangle()
                }
                .padding()
            }
        }
        
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView()
            .preferredColorScheme(.dark)
            .environmentObject(HabbitViewModel())
    }
}

struct OrangeRectangle: ViewModifier {
    func body(content: Content) -> some View {
        ZStack(alignment: .bottomTrailing) {
            content
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(.orange)
                        .opacity(0.96)
                )
        }
    }
}

extension View {
    func orangeRectangle() -> some View {
        self.modifier(OrangeRectangle())
    }
}


struct CalendarView: UIViewRepresentable {
    @EnvironmentObject var habitViewModel: HabbitViewModel
    var habits: FetchedResults<Habit>
    var calendar = FSCalendar()
    
    
    var daysComplete: [String] {
        var completeDays = [String]()
        for i in habits {
            completeDays += i.daysComplete!
            print(i.daysComplete!)
        }
        
        return completeDays
    }
    //Sample
    //var datesWithEvent = ["2022-06-03", "2022-06-06", "2022-06-12", "2022-06-25"]
    
    func updateUIView(_ uiView: FSCalendar, context: Context) {
    }
    
    
    //MARK: Make UI
    func makeUIView(context: Context) -> FSCalendar {
        calendar.delegate = context.coordinator
        calendar.dataSource = context.coordinator
        
        calendar.appearance.eventDefaultColor = .green
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
        
        func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
            
            let dateString = parent.habitViewModel.extractDate(date: date, format: "yyyy-MM-dd")
            
            if parent.daysComplete.contains(dateString) {
                return 1
            }
            
            return 0
        }
    }
}
