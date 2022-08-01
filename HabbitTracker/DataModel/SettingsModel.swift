//
//  SettingModel.swift
//  HabbitTracker
//
//  Created by Павел Кай on 01.08.2022.
//

import Foundation
import SwiftUI

class Settings: ObservableObject {
    static let shared = Settings()
    
    @AppStorage("whiteMode") var whiteMode = false {
            didSet {
                objectWillChange.send()
            }
        }
}
