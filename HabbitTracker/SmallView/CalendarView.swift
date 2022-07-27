//
//  CalendarView.swift
//  HabbitTracker
//
//  Created by Павел Кай on 25.07.2022.
//

import SwiftUI
import UIKit
import FSCalendar

struct CalendarView: UIViewRepresentable {
    @EnvironmentObject var habitViewModel: HabitViewModel
    @Environment(\.managedObjectContext) var moc
    var habit: Habit
    var calendar = FSCalendar()
    
    func updateUIView(_ uiView: FSCalendar, context: Context) {
    }
    
    //MARK: alertComplete controller implementation
    func alertComplete(dateString: String, date: Date) {
        let title: String = "Mark day"
        let message: String = "Do you want mark day as complete?"
        
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let completeAction = UIAlertAction(title: "Mark habit as complete", style: .default) { (action: UIAlertAction) in
            
            if let remove = habit.daysLost?.firstIndex(where: { dayDate in
                dayDate == dateString
            }) {
                habit.daysLost?.remove(at: remove)
            }
            
            habit.daysComplete?.append(dateString)
            habit.streak += 1
            
            calendar.deselect(date)
            calendar.reloadData()
            habitViewModel.reloadView()
            try? moc.save()
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (action: UIAlertAction) in
            calendar.deselect(date)
            calendar.reloadData()
        }
        
        alertVC.addAction(completeAction)
        alertVC.addAction(cancelAction)
        
        let viewController = UIApplication.shared.windows.first!.rootViewController!
        viewController.present(alertVC, animated: true, completion: nil)
    }
    
    //MARK: alertUncomplete controller implementation
    func alertUncomplete(dateString: String, date: Date) {
        let title: String = "Mark day"
        let message: String = "Do you want mark day as uncomplete?"
        
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let uncompleteAction = UIAlertAction(title: "Mark habit as uncomplete", style: .default) { (action: UIAlertAction) in
            
            if let remove = habit.daysComplete?.firstIndex(where: { dayDate in
                dayDate == dateString
            }) {
                habit.daysComplete?.remove(at: remove)
                habit.streak -= 1
   
                calendar.deselect(date)
                calendar.reloadData()
                habitViewModel.reloadView()
                try? moc.save()
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (action: UIAlertAction) in
            calendar.deselect(date)
            calendar.reloadData()
        }
        
        alertVC.addAction(uncompleteAction)
        alertVC.addAction(cancelAction)
        
        let viewController = UIApplication.shared.windows.first!.rootViewController!
        viewController.present(alertVC, animated: true, completion: nil)
    }
    
    //MARK: Make UI
    func makeUIView(context: Context) -> FSCalendar {
        calendar.delegate = context.coordinator
        calendar.dataSource = context.coordinator
        
        calendar.appearance.headerDateFormat = "dd MMMM yyyy"
        
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.weekdayTextColor = .black
        
        calendar.appearance.weekdayFont = UIFont.systemFont(ofSize: 12)
        calendar.appearance.titleFont = UIFont.systemFont(ofSize: 18)
        
        calendar.appearance.todayColor = .none
        calendar.appearance.todaySelectionColor = .none
        calendar.appearance.selectionColor = .blue
        calendar.appearance.titleTodayColor = .blue
        
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
        
        func maximumDate(for calendar: FSCalendar) -> Date {
            Date.now
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
        
        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            
            let dateString = parent.habitViewModel.extractDateToString(date: date, format: "yyyy-MM-dd")
            
            guard parent.habit.frequency != nil else {
                return
            }
            
            guard parent.habit.daysComplete != nil else {
                return
            }
            
            guard parent.habit.daysLost != nil else {
                return
            }

            if parent.habit.frequency!.contains(parent.habitViewModel.extractDateToString(date: date, format: "EEEE")) {
                
                if parent.habit.daysComplete!.contains(dateString) {
                    parent.alertUncomplete(dateString: dateString, date: date)
                } else {
                    parent.alertComplete(dateString: dateString, date: date)
                }
                
            }
            
        }
        
        func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
           let size = image.size

           let widthRatio  = targetSize.width  / size.width
           let heightRatio = targetSize.height / size.height

           // Figure out what our orientation is, and use that to form the rectangle
           var newSize: CGSize
           if(widthRatio > heightRatio) {
               newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
           } else {
               newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
           }

           // This is the rect that we've calculated out and this is what is actually used below
           let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

           // Actually do the resizing to the rect using the ImageContext stuff
           UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
           image.draw(in: rect)
           let newImage = UIGraphicsGetImageFromCurrentImageContext()
           UIGraphicsEndImageContext()

           return newImage!
       }

        
        func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
            
            if parent.habitViewModel.showCalendarCirclesFromDateCreatedToDateNow(habit: parent.habit, date: date) {
            return resizeImage(image: .init(systemName: "circle")!, targetSize: CGSize(width: 27, height: 27))
            } else {
                return nil
            }
        }
        
        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, imageOffsetFor date: Date) -> CGPoint {
            CGPoint(x: 0, y: -1)
        }
        
    }
}

struct CalendarView_Previews: PreviewProvider {
    
    static let context = DataController().container.viewContext
    static let habbit = Habit(context: context)
    
    static var previews: some View {
        CalendarView(habit: habbit)
            .environmentObject(HabitViewModel())
            .preferredColorScheme(.dark)
            .orangeRectangle()
            .frame(height: 210)
            .padding()
    }
}
