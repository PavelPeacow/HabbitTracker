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
    @EnvironmentObject var habitViewModel: HabitViewModel
    var habitItem: Habit
    
    @State private var isShowingAlert = false
    @State private var isShowingSheet = false
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
                    
                    Text(habitItem.name ?? "Habit")
                        .font(.largeTitle)
                    
                    CalendarView(habit: habitItem)
                        .environmentObject(habitViewModel)
                        .orangeRectangle()
                        .frame(height: 220)
                        .padding()
                    
                    VStack {
                        Text("Selected frequency")
                            .textHeadline()
                        HStack {
                            habitFrequency
                        }
                    }
                    .padding()
                    .orangeRectangle()
                    .padding(.horizontal, 16)
                    
                    VStack {
                        HorizontalBarChartView(dataPoints: habitViewModel.getChartData(daysCompleteCount: daysCompleteCount, daysLostCount: daysLostCount))
                            .textHeadline()
                            .padding()
                            .orangeRectangle()
                            .fixedSize()
                            .padding()
                    }
                    
                    HStack {
                        HStack {
                            Text("Days in a row 7")
                                .textHeadline()
                            Image(systemName: "flame")
                                .textHeadline()
                        }
                        .padding()
                        .orangeRectangle()
                        
                        HStack {
                            if habitItem.isRemainderOn {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(.black)
                                Text((habitItem.remainderDate?.formatted(.dateTime.hour().minute()))!)
                                    .textHeadline()
                            } else {
                                Image(systemName: "bell.slash.fill")
                                    .textHeadline()
                            }
                            
                        }
                        .padding()
                        .orangeRectangle()
                    }
                    
                    HStack(spacing: 25) {
                        Button {
                            isShowingSheet.toggle()
                        } label: {
                            Text("Change habit")
                                .textHeadline()
                                .padding()
                                .buttonGradient(shadowColor: .blue, firstGradColor: .blue, secondGradColor: .cyan)
                        }
                        
                        
                        Button {
                            isShowingAlert.toggle()
                        } label: {
                            Text("Delete habit")
                                .textHeadline()
                                .padding()
                                .buttonGradient(shadowColor: .red, firstGradColor: .red, secondGradColor: .orange)
                        }
                    }
                    .padding()
                    
                }
                .alert("Are you shure?", isPresented: $isShowingAlert) {
                    Button("Delete", role: .destructive) {
                        habitViewModel.deleteHabit(habit: habitItem, context: moc)
                    }
                }
                .sheet(isPresented: $isShowingSheet) {
                    habitViewModel.resetData()
                } content: {
                    ChangeHabitVIew(habit: habitItem)
                        .environmentObject(HabitViewModel())
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    @ViewBuilder
    private var habitFrequency: some View {
        let weekDays = Calendar.current.weekdaySymbols
        ForEach(weekDays, id: \.self) { day in
            let index = habitItem.frequency?.firstIndex { value in
                return value == day
            } ?? -1
            Text(day.prefix(2))
                .foregroundColor(.white)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background {
                    Circle()
                        .fill(index != -1 ? Color(habitItem.color ?? "Color-1") : Color(habitItem.color ?? "Color-1").opacity(0.4))
                }
        }
    }
}


//MARK: FSCalendar implementation
struct CalendarView: UIViewRepresentable {
    @EnvironmentObject var habitViewModel: HabitViewModel
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
            
            let dateString = parent.habitViewModel.extractDateToString(date: date, format: "yyyy-MM-dd")
            
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
            .environmentObject(HabitViewModel())
    }
}
