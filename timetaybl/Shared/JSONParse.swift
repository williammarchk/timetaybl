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
        
        //print(lesson.endTime)
        
        if !existingSubject {
            subjects.append(Subject(name: jsonLesson.subjectName, color: Color(white: 1), lessons: [lesson]))
        } else {
            subjects[subjectIndex].lessons.append(lesson)
        }
    }

    /*
    print(unwrappedJSON)
    var n = 0
    
    while n < unwrappedJSON.count-1 {
        let ce = unwrappedJSON[n]
        let ne = unwrappedJSON[n+1]
        
        var timing: [String] = []
        var start_time = "10:00"
        var end_time = "10:40"
        var sm = 1
        var sh = 0
        var em = 1
        var eh = 0
        
        var lel = ((ne.startHour * 60) + ne.startMinute) - ((ce.endHour * 60) + ce.endMinute)
        if (ce.endHour < 16) {
            
            
            while (lel >= 60) {
                if (ce.endHour == 2 && ce.endMinute == 30) {
                    if (ce.endMinute + 5 >= 60) {
                        //print(ce.endMinute)
                        sm = 0
                        sh = ce.endHour + 1
                        start_time = String(sh) + ":" + String(00)
                    } else {
                        sh = ce.endHour
                        sm = ce.endMinute + 5
                        start_time = String(sh) + ":" + String(sm)
                    }
                    
                    lel = lel - 30
                    print("Time left is: " + String(lel))
                } else {
                    if (ce.endMinute + 5 >= 60) {
                        sm = 0
                        sh = ce.endHour + 1
                        start_time = String(sh) + ":" + String(00)
                    } else {
                        sh = ce.endHour
                        sm = ce.endMinute + 5
                        start_time = String(sh) + ":" + String(sm)
                    }
                    end_time = String(sh+1) + ":" + String(sm)
                    print(start_time + "-" + end_time)
                    lel = lel - 65
                    //ce.append(subjectName: "Free Period", location: "", week: 1, day: 0, startHour: sh, endHour: sh+1, startMinute: sm, endMinute: sm)
                }
            }
            print(lel)
        }
        let dlld = ne
        
        //print(dlld)
        //ce.append(subjectName: "Break", location: "", week: 1, day: 0, startHour: 2, endHour: 2, startMinute: 35, endMinute: 55)
        //ce.append(subjectName: "Free Period", location: "", week: 1, day: 0, startHour: 12, endHour: 1, startMinute: 25, endMinute: 25)
        
        
        /*
        if (ce.endHour < 16) {
            if ((((ne.startHour * 60) + ne.startMinute) - ((ce.endHour * 60) + ce.endMinute)) > 5 && (((ne.startHour * 60) + ne.startMinute) - ((ce.endHour * 60) + ce.endMinute)) < 30) {
                
                print(ce.endMinute)
                if (ce.endMinute + 5 >= 60) {
                    print(ce.endMinute)
                    sh = ce.endHour + 1
                    start_time = String(sh) + ":" + String(00)
                } else {
                    sh = ce.endHour
                    sm = ce.endMinute + 5
                    start_time = String(sh) + ":" + String(sm)
                }
                
                if (ne.startMinute - 5 < 0) {
                    eh = ne.startHour - 1
                    end_time = String(eh) + ":" + String(55)
                } else {
                    eh = ne.startMinute
                    em = ne.startHour - 5
                    end_time = String(eh) + ":" + String(em)
                }
                
                var gap = (((ce.endHour * 60) + ce.endMinute) - ((ne.startHour * 60) + ne.startMinute))
                print (gap)
                print("Distance between periods" + String(gap))
                //print("Break is at " + start_time + "-" + end_time)
            
            } /*else if ((((ce.endHour * 60) + ce.endMinute) - ((ne.startHour * 60) + ne.startMinute)) > 30) {
                
                if (ce.endMinute + 5 >= 60) {
                    sh = ce.endHour + 1
                    start_time = String(sh) + ":" + String(00)
                } else {
                    sh = ce.endHour
                    sm = ce.endMinute + 5
                    start_time = String(sh) + ":" + String(sm)
                }
                
                if (ne.startMinute - 5 < 0) {
                    eh = ne.startHour - 1
                    end_time = String(eh) + ":" + String(55)
                } else {
                    eh = ne.startMinute
                    em = ne.startHour - 5
                    end_time = String(eh) + ":" + String(em)
                }
                
                print("Study Period" + start_time + "-" + end_time)
            }*/
        }
        */
        n += 1
    }
    */
    /*var x = 1;
    while (x < 2) {
        print("startHour" + String(unwrappedJSON[1].startHour))
        print("startMinute" + String(unwrappedJSON[1].startMinute))
        x += 1
    }*/

    
    for subject in subjects {
        //print(subject.name)
    }
    
    return subjects
}
