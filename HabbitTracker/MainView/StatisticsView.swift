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
                    VStack {
                        Text(habitItem.name ?? "Habit")
                            .font(.largeTitle)
                    }
                    
                    CalendarView(habit: habitItem)
                        .environmentObject(habitViewModel)
                        .orangeRectangle()
                        .frame(height: 220)
                        .padding()
                    
                    VStack {
                        Text("Selected frequency")
                            .textHeadline()
                        HStack {
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
                        habitViewModel.deleteHabit(context: moc, habitItem: habitItem)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        
    }
}


//MARK: Custom modifiers
struct OrangeRectangle: ViewModifier {
    func body(content: Content) -> some View {
            content
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(.orange)
                        .opacity(0.96)
                        .shadow(color: .orange, radius: 4, x: 0, y: 0)
                )
    }
}

struct ButtonGradient: ViewModifier {
    
    let shadowColor: Color
    let firstGradientColor: Color
    let secondGradientColor: Color
    
    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(gradient: Gradient(colors: [firstGradientColor, secondGradientColor]), startPoint: .trailing, endPoint: .leading)
                    .mask({
                        RoundedRectangle(cornerRadius: 20)
                    })
                    .shadow(color: shadowColor, radius: 8, x: 0, y: 0)
            )
    }
}

struct TextHeadline: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(.black)
    }
}

extension View {
    func orangeRectangle() -> some View {
        self.modifier(OrangeRectangle())
    }
    
    func buttonGradient(shadowColor: Color, firstGradColor: Color, secondGradColor: Color) -> some View {
        self.modifier(ButtonGradient(shadowColor: shadowColor, firstGradientColor: firstGradColor, secondGradientColor: secondGradColor))
    }
    
    func textHeadline() -> some View {
        self.modifier(TextHeadline())
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
