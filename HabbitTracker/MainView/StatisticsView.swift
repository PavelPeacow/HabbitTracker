//
//  StatisticsView.swift
//  HabbitTracker
//
//  Created by Павел Кай on 23.06.2022.
//

import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var habitViewModel: HabitViewModel
    @Environment(\.managedObjectContext) var moc
    
    @State private var isShowingAlert = false
    @State private var isShowingSheet = false
    
    var habitItem: Habit
    
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
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Circle()
                                .foregroundColor(.green)
                                .frame(width: 15, height: 15)
                            
                            Text("\(habitItem.daysComplete?.count ?? 0) Days Complete")
                        }
                        
                        HStack {
                            Circle()
                                .foregroundColor(.red)
                                .frame(width: 15, height: 15)
                            
                            Text("\(habitItem.daysLost?.count ?? 0) Days lost")
                        }
                    }
                    .textHeadline()
                    .padding()
                    .orangeRectangle()
                    .padding()
                    
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
                        .fill(index != -1 ? Color(habitItem.color ?? "Color-1") : Color(habitItem.color ?? "Color-1").opacity(0.2))
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
            .environmentObject(HabitViewModel())
    }
}
