//
//  FrontEndTestApp.swift
//  FrontEndTest
//
//  Created by Kresimir Tokic on 2/21/21.
//

import SwiftUI
import CoreData

@main
struct FrontEndTestApp: App {
    let persistenceController = PersistenceController.shared
    @Environment(\.scenePhase) var scenePhase
    var body: some Scene {
        WindowGroup {
            ContentView().environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .onChange(of: scenePhase) { _ in
            persistenceController.save()
        }
    }
}
