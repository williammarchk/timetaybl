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
    
    // Adds free periods, break and lunch when not on calender
    var n = 0
    
    while n < 83 {
        let ce = unwrappedJSON[n]
        let ne = unwrappedJSON[n+1]
        
        var sm = 1
        var sh = 0
        var em = 1
        var eh = 0
        let pd = ce.day
        let pw = ce.week
        var case14 = false
        
        var lel = ((ne.startHour * 60) + ne.startMinute) - ((ce.endHour * 60) + ce.endMinute)
        if (lel < 0 && ce.day != 4) {
            lel = ((16 * 60)) - ((ce.endHour * 60) + ce.endMinute)
        } else if (lel < 0 && ce.day == 4) {
            ((14 * 60) + 20) - ((ce.endHour * 60) + ce.endMinute)
        }
                
        if (ce.endHour == 14 && ce.endMinute == 55) {
            case14 = true
        }
        
        if (lel > 60 && (ce.endHour != 14 || case14 == true)) {
            if (ce.day != 4) {
                lel = lel - 65
            } else if (ce.day == 4) {
                lel = lel - 55
            }
            
            if (ce.endMinute + 5 >= 60) {
                sm = 0
                sh = ce.endHour + 1
            } else {
                sh = ce.endHour
                sm = ce.endMinute + 5
            }
            
            if (ce.day == 4) {
                if (sm + 50 > 55) {
                    eh = sh + 1
                    em = (sm + 50)-60
                } else {
                    eh = sh
                    em = sm + 50
                }
            } else {
                eh = sh+1
                em = sm
            }
            
            unwrappedJSON.insert(APIElement(subjectName: "Free Period", location: "", week: pw, day: pd, startHour: sh, endHour: eh, startMinute: sm, endMinute: em), at: n+1)
        } else if (ce.endHour == 14 && lel > 5) {
            
            if (ce.endMinute + 5 >= 60) {
                sm = 0
                sh = ce.endHour + 1
            } else {
                sh = ce.endHour
                sm = ce.endMinute + 5
            }
            
            if (ne.startHour < 15) {
                eh = sh
            } else {
                eh = ne.startHour-1
            }
            
            if (ne.startMinute-5 < 0) {
                em = 55
            } else {
                em = ne.startMinute-5
            }
            
            unwrappedJSON.insert(APIElement(subjectName: "Break", location: "", week: pw, day: pd, startHour: sh, endHour: eh, startMinute: sm, endMinute: em), at: n+1)
        } else if (ce.day == 4 && lel == 55) {
            
            if (ce.endMinute + 5 >= 60) {
                sm = 0
                sh = ce.endHour + 1
            } else {
                sh = ce.endHour
                sm = ce.endMinute + 5
            }
            
            if (ce.endMinute+45 >= 60) {
                em = (sm + 45)-60
                eh = sh + 1
            } else {
                em = sm + 45
                eh = sh
            }
            
            unwrappedJSON.insert(APIElement(subjectName: "Lunch", location: "", week: pw, day: pd, startHour: sh, endHour: eh, startMinute: sm, endMinute: em), at: n+1)
        }
        
        print(unwrappedJSON[n])
        
        n += 1
    }
    
    //
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
        
        //print(lesson.endTime)
        
        if !existingSubject {
            subjects.append(Subject(name: jsonLesson.subjectName, color: Color(white: 1), lessons: [lesson]))
        } else {
            subjects[subjectIndex].lessons.append(lesson)
        }
    }
    
    for subject in subjects {
        //print(subject.name)
    }
    
    return subjects
}
