//
//  AddFirstHabitView.swift
//  HabbitTracker
//
//  Created by Павел Кай on 27.07.2022.
//

import SwiftUI

struct AddFirstHabitView: View {
    @EnvironmentObject var habitViewModel: HabitViewModel
    
    var body: some View {
        Button {
            habitViewModel.isShowingAddHabitSheet.toggle()
        } label: {
            HStack {
                Image(systemName: "plus.circle")
                    .foregroundColor(.white)
                Text("New habit")
                    .foregroundColor(.white)
            }
            .padding()
            .background(
                Capsule()
                    .foregroundColor(.gray)
                    .opacity(0.2)
            )
        }
        
    }
}

struct AddFirstHabitView_Previews: PreviewProvider {
    static var previews: some View {
        AddFirstHabitView()
            .preferredColorScheme(.dark)
            .environmentObject(HabitViewModel())
    }
}
