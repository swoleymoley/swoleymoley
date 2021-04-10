//
//  Dorkout+CoreDataProperties.swift
//  FrontEndTest
//
//  Created by Jeff Halley on 4/8/21.
//
//

import Foundation
import CoreData
import EventKit

extension Dorkout {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Dorkout> {
        return NSFetchRequest<Dorkout>(entityName: "Dorkout")
    }

    @NSManaged public var date: Date?
    @NSManaged public var day: Int16
    @NSManaged public var fractionOfMax: Float
    @NSManaged public var workout_id: String?
    @NSManaged public var program_id: String?
    @NSManaged public var lift: String
    @NSManaged public var reps: Int16
    @NSManaged public var sets: Int16
    @NSManaged public var weight: Float
    @NSManaged public var weekNumber: Int16
    
    func setWorkoutWeight(maxesDict: [String: Float]) {
        if self.lift != "meet" {
            let max_weight = maxesDict[self.lift] ?? 0.0
            self.weight = self.fractionOfMax * max_weight
        }
    }

    func setWorkoutDate(startDate: Date) {
        var dayComponent = DateComponents()
        dayComponent.day = Int(self.day)
        let theCalendar = Calendar.current
        self.date = theCalendar.date(byAdding: dayComponent, to: startDate)!
    }
    
    func getWorkoutDescription() -> String{
        let description = String(self.lift + " day!\n" + String(self.weight) + " lbs for " + String(self.sets) + " sets of " + String(self.reps) + " reps\n View on swoleymoley://open")
        return description
    }
    
    func addWorkoutToCalendar(completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
        let eventStore = EKEventStore()

        eventStore.requestAccess(to: .event, completion: { (granted, error) in
            if (granted) && (error == nil) {
                let event = EKEvent(eventStore: eventStore)
                event.title = "SwoleyMoley Workout: " + self.lift
                event.startDate = self.date
                event.endDate = self.date
                event.notes = self.getWorkoutDescription()
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(event, span: .thisEvent)
                } catch let e as NSError {
                    completion?(false, e)
                    return
                }
                completion?(true, nil)
            } else {
                completion?(false, error as NSError?)
            }
        })
    }

}

extension Dorkout : Identifiable {

}
