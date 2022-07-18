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
                    
                    CalendarView(habit: habitItem)
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
            .navigationTitle(habitItem.name ?? "Habit")
        }
       
    }
}

//MARK: Custom modifier
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



//MARK: FSCalendar implementation
struct CalendarView: UIViewRepresentable {
    @EnvironmentObject var habitViewModel: HabbitViewModel
    var habit: Habit
    var calendar = FSCalendar()
    
    
    func updateUIView(_ uiView: FSCalendar, context: Context) {
    }
    
    
    //MARK: Make UI
    func makeUIView(context: Context) -> FSCalendar {
        calendar.delegate = context.coordinator
        calendar.dataSource = context.coordinator
        
        calendar.appearance.eventDefaultColor = .green
        calendar.appearance.headerDateFormat = "dd MMMM yyyy EEEE"
        
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.weekdayTextColor = .black
        calendar.appearance.weekdayFont = UIFont.systemFont(ofSize: 12)
        calendar.appearance.titleFont = UIFont.systemFont(ofSize: 18)
        calendar.appearance.todayColor = .black
        
        return calendar
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    //MARK: Calendar logic
    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
        var parent: CalendarView
        
        init(_ parent: CalendarView) {
            self.parent = parent
        }
        
        
        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {

            let dateString = parent.habitViewModel.extractDate(date: date, format: "yyyy-MM-dd")
            
            guard parent.habit.daysComplete != nil else {
                return nil
            }
            
            guard parent.habit.daysLost != nil else {
                return nil
            }

            if parent.habit.daysComplete!.contains(dateString) {
                return .green
            } else if parent.habit.daysLost!.contains(dateString) {
                return .red
            }
            
            return nil
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
