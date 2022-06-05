//
//  HabbitClass.swift
//  HabbitTracker
//
//  Created by Павел Кай on 04.06.2022.
//

import Foundation

struct HabbitItem: Identifiable, Codable, Equatable {
    var id = UUID()
    var nameHabbit: String
    var decriptionHabbit: String
    var streak: Int
    var color: String
    var frequency: [String]
}

class Habbits: ObservableObject {
    @Published var habbits = [HabbitItem]()
}
