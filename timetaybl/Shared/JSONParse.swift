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
    let week, day: Int
    var startHour, endHour: Int
    var startMinute, endMinute: Int

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
    
    var unwrappedJSON = decodedJSON!
    
    var subjects: [Subject] = []
    
    var i = 0
    while i + 1 < unwrappedJSON.count {
        let thisLesson = unwrappedJSON[i]
        let nextLesson = unwrappedJSON[i + 1]
        
        // Check if double
        if  thisLesson.endHour == nextLesson.startHour &&
            thisLesson.endMinute == (nextLesson.startMinute - 5) &&
            thisLesson.subjectName == nextLesson.subjectName
        {
            unwrappedJSON[i].endHour = nextLesson.endHour
            unwrappedJSON[i].endMinute = nextLesson.endMinute
            
            unwrappedJSON.remove(at: i + 1)
        }
        
        i += 1
    }
    
    for jsonLesson in unwrappedJSON {
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
