//
//  DateExtension.swift
//  LifeHub
//
//  Created by Jenish Shah on 2025-06-22.
//

import Foundation

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
    
    func getWeekDay()-> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let weekDay = dateFormatter.string(from: self)
        return weekDay
    }
    
    func get12HoursTimeFromat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let time12HoursFormat = dateFormatter.string(from: self)
        return time12HoursFormat
    }
}
