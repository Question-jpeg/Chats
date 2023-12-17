//
//  Statuses.swift
//  Chats
//
//  Created by Игорь Михайлов on 12.12.2023.
//

import Foundation

enum Statuses: String, CaseIterable, Codable {
    case available = "Available"
    case busy = "Busy"
    case atSchool = "At school"
    case atTheMovies = "At the movies"
    case atWork = "At work"
    case batteryAboutToDie = "Battery about to die"
    case inAMeeting = "In a meeting"
    case atTheGym = "At the gym"
    case sleeping = "Sleeping"
    case urgentCallsOnly = "Urgent calls only"
}
