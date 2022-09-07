//
//  TimeTable.swift
//  timetaybl (macOS)
//
//  Created by MACKE, Mats on 07.09.22.
//

import Foundation
import SwiftUI

struct Timetable {
    var subjects: [Subject]
}

struct Subject {
    var name: String
    var color: Color
    var lessons: [Lesson]
}

struct Lesson {
    var day: Day
    var startTime: TimeOfDay
    var endTime: TimeOfDay
    var room: String
}

struct TimeOfDay {
    var hourNumber: Int // From 0 to 23
    var minuteNumber: Int // From 0 to 60
}

struct Day {
    var isWeekTwo: Bool
    var day: Int // From 1 to 7
}
