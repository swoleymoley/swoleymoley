//
//  Exercise+CoreDataProperties.swift
//  FrontEndTest
//
//  Created by Jeff Halley on 4/8/21.
//
//

import Foundation
import CoreData
import EventKit

extension Exercise {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Exercise> {
        return NSFetchRequest<Exercise>(entityName: "Exercise")
    }

    @NSManaged public var date: Date
    @NSManaged public var day: Int16
    @NSManaged public var fractionOfMax: Float
    @NSManaged public var workoutId: String
    @NSManaged public var programId: String
    @NSManaged public var lift: String
    @NSManaged public var reps: Int16
    @NSManaged public var sets: Int16
    @NSManaged public var weight: Float
    @NSManaged public var weekNumber: Int16
    @NSManaged public var needsWarmups: Bool
    
    func setExerciseWeight(maxesDict: [String: Float]) {
        if self.lift != "meet" {
            let maxWeight = maxesDict[self.lift] ?? 0.0
            self.weight = self.fractionOfMax * maxWeight
        }
    }

    func setExerciseDate(startDate: Date) {
        var dayComponent = DateComponents()
        dayComponent.day = Int(self.day)
        let theCalendar = Calendar.current
        self.date = theCalendar.date(byAdding: dayComponent, to: startDate)!
    }
    
    func getExerciseDescription() -> String{
        let description = (String(self.lift) + ": " + String(self.weight) + " lbs for " + String(self.sets) + " sets of " + String(self.reps) + "\n")
        return description
    }
    
    func addExerciseToCalendar(completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
        let eventStore = EKEventStore()

        eventStore.requestAccess(to: .event, completion: { (granted, error) in
            if (granted) && (error == nil) {
                let event = EKEvent(eventStore: eventStore)
                event.title = "SwoleyMoley Workout: " + self.lift
                event.startDate = self.date
                event.endDate = self.date
                event.notes = self.getExerciseDescription()
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

extension Exercise : Identifiable {

}
