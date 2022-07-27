//
//  AddFirstHabitView.swift
//  HabbitTracker
//
//  Created by Павел Кай on 27.07.2022.
//

import SwiftUI

struct AddFirstHabitView: View {
    @Binding var isShowingAddView: Bool
    
    var body: some View {
        Button {
            isShowingAddView.toggle()
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
        AddFirstHabitView(isShowingAddView: .constant(false))
            .preferredColorScheme(.dark)
    }
}
