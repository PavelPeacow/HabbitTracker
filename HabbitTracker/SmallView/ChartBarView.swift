//
//  ChartBarView.swift
//  HabbitTracker
//
//  Created by Павел Кай on 12.07.2022.
//

import SwiftUI
import SwiftUICharts

struct ChartBarView: View {
    let daysCompleteCount: Double
    
    var body: some View {
        
        let daysComplete = Legend(color: .green, label: "Days complete", order: 1)
        let daysLost = Legend(color: .red, label: "Days lost", order: 2)

        let points: [DataPoint] = [
            .init(value: daysCompleteCount, label: "\(daysCompleteCount.formatted())", legend: daysComplete),
            .init(value: 3, label: "2", legend: daysLost)
        ]

        HorizontalBarChartView(dataPoints: points)
        
    }
}

struct ChartBarView_Previews: PreviewProvider {
    static var previews: some View {
        ChartBarView(daysCompleteCount: 1)
    }
}
