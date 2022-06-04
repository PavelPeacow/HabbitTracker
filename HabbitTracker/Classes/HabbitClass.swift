//
//  HabbitClass.swift
//  HabbitTracker
//
//  Created by Павел Кай on 04.06.2022.
//

import Foundation

struct HabbitItem: Identifiable, Codable {
    var id = UUID()
    var nameHabbit: String
    var decriptionHabbit: String
    var streak: Int
}

class Habbits: ObservableObject {
    @Published var habbits = [HabbitItem]()
}
