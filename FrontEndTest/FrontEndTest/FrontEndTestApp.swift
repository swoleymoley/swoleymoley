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
    @State var launchURL: URL = URL(fileURLWithPath: "https://exampleplaceholder.com")
    var body: some Scene {
        WindowGroup {
            ContentView(launchURL: $launchURL).environment(\.managedObjectContext, persistenceController.container.viewContext).onOpenURL { url in
                launchURL = url
                
              }
        }
        .onChange(of: scenePhase) { _ in
            persistenceController.save()
        }
    }
}
