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
    var habitItem: Habit
    
    @State private var isShowingAlert = false
    @Environment(\.managedObjectContext) var moc
    
    private var daysCompleteCount: Double {
        var completeDays = 0.0
        completeDays += Double(habitItem.daysComplete?.count ?? 0)
        return completeDays
    }
    
    private var daysLostCount: Double {
        var lostDays = 0.0
        lostDays += Double(habitItem.daysLost?.count ?? 0)
        return lostDays
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Text("Statistic")
                    CalendarView(habits: habitItem)
                        .environmentObject(habitViewModel)
                        .orangeRectangle()
                        .frame(height: 260)
                        .padding()
                    
                    Spacer()
                    
                    VStack {
                        
                        HorizontalBarChartView(dataPoints: habitViewModel.getChartData(daysCompleteCount: daysCompleteCount, daysLostCount: daysLostCount))
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding()
                            .orangeRectangle()
                            .fixedSize()
                            .padding()
                        
                        HStack {
                            Text("Days in a row 7")
                                .font(.headline)
                                .foregroundColor(.black)
                            Image(systemName: "flame")
                                .foregroundColor(.black)
                        }
                        .padding()
                        .orangeRectangle()
                        
                        Button {
                            isShowingAlert.toggle()
                        } label: {
                            Text("Delete habit")
                                .font(.headline)
                                .padding()
                                .orangeRectangle()
                                .padding()
                        }
                    }
                    .padding()
                    .alert("Are you shure?", isPresented: $isShowingAlert) {
                        Button("Delete", role: .destructive) {
                            habitViewModel.deleteHabit(context: moc, habitItem: habitItem)
                        }
                    }
                }
            }
        }
        
    }
}

struct StatisticsView_Previews: PreviewProvider {
    
    static let context = DataController().container.viewContext
    static let habbit = Habit(context: context)
    
    static var previews: some View {
        StatisticsView(habitItem: habbit)
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
    var habits: Habit
    var calendar = FSCalendar()
    
    
    var daysComplete: [String] {
        var completeDays = [String]()
        for i in habits.daysComplete ?? [] {
            completeDays.append(i)
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
