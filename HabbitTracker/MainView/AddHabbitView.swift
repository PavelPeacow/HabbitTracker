//
//  AddHabbitView.swift
//  HabbitTracker
//
//  Created by Павел Кай on 04.06.2022.
//

import SwiftUI

struct AddHabbitView: View {
   @State var nameHabbit = ""
   @State var decriptionHabbit = ""
    
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Enter name of habbit", text: $nameHabbit)
                }
                
                Section {
                    TextField("Enter description", text: $decriptionHabbit)
                }
                
                Section {
                    Button {
                        
                    } label: {
                        Text("Submit")
                    }
                }
            }
            .navigationTitle("Add new habbit")
        }
    }
}

struct AddHabbitView_Previews: PreviewProvider {
    static var previews: some View {
        AddHabbitView()
    }
}
