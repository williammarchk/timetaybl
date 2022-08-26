//
//  timetayblApp.swift
//  Shared
//
//  Created by MARCH-KRAMER, William on 26.08.22.
//

import SwiftUI

@main
struct timetayblApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
