//
//  JSONParse.swift
//  timetaybl (macOS)
//
//  Created by MACKE, Mats on 07.09.22.
//

import Foundation

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

func parseJSON(json: String) -> Timetable {
    var decodedJSON = try? JSONDecoder().decode(API.self, from: json.data(using: .utf8)!)
    
    print(decodedJSON)
    
    return Timetable(subjects: [])
}
