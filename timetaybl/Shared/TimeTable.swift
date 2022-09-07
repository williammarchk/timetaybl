//
//  TimeTable.swift
//  timetaybl (macOS)
//
//  Created by MACKE, Mats on 07.09.22.
//

import Foundation
import SwiftUI

typealias TimeTable = [Subject]

struct Subject : Hashable {
    var name: String
    var color: Color
    var lessons: [Lesson]
}

struct Lesson : Hashable {
    var day: Day
    var startTime: TimeOfDay
    var endTime: TimeOfDay
    var room: String
}

struct TimeOfDay : Hashable {
    var hour: Int // From 0 to 23
    var minute: Int // From 0 to 59
}

struct Day : Hashable {
    var week: Int // 1 or 2
    var day: Int // From 0 to 4, Monday to Friday
}
