//
//  JSONParse.swift
//  timetaybl (macOS)
//
//  Created by MACKE, Mats on 07.09.22.
//

import Foundation
import SwiftUI

struct APIElement: Codable {
    let subjectName, location: String
    let week, day, startHour, endHour: Int
    let startMinute, endMinute: Int

    enum CodingKeys: String, CodingKey {
        case subjectName = "SubjectName"
        case location = "Location"
        case week = "Week"
        case day = "Day"
        case startHour = "StartHour"
        case endHour = "EndHour"
        case startMinute = "StartMinute"
        case endMinute = "EndMinute"
    }
}

typealias API = [APIElement]

func parseJSON(json: String) -> TimeTable {
    let decodedJSON = try? JSONDecoder().decode(API.self, from: json.data(using: .utf8)!)
    
    var subjects: [Subject] = []
    
    for jsonLesson in decodedJSON! {
        var existingSubject: Bool = false
        var subjectIndex = 0
        
        for (i, subject) in subjects.enumerated() {
            if jsonLesson.subjectName == subject.name {
                existingSubject = true
                subjectIndex = i
            }
        }
        
        let lesson = Lesson(
            day: Day(
                week: jsonLesson.week,
                day: jsonLesson.day
            ),
            startTime: TimeOfDay(
                hour: jsonLesson.startHour,
                minute: jsonLesson.startMinute
            ),
            endTime: TimeOfDay(
                hour: jsonLesson.endHour,
                minute: jsonLesson.endMinute
            ),
            room: jsonLesson.location
        )
        
        if !existingSubject {
            subjects.append(Subject(name: jsonLesson.subjectName, color: Color(white: 1), lessons: [lesson]))
        } else {
            subjects[subjectIndex].lessons.append(lesson)
        }
    }

    for subject in subjects {
        print(subject.name)
    }
    
    return subjects
}
