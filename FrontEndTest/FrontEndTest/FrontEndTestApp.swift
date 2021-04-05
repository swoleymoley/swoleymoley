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
    let persistentContainer: NSPersistentContainer = {
          let container = NSPersistentContainer(name: "SwoleyMoleyDataModel")
          container.loadPersistentStores(completionHandler: { (storeDescription, error) in
              if let error = error as NSError? {
                  fatalError("Unresolved error \(error), \(error.userInfo)")
              }
          })
          return container
      }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
