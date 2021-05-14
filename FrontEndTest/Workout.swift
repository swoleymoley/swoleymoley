//
//  Workout.swift
//  FrontEndTest
//
//  Created by Jeff Halley on 4/24/21.
//

import Foundation
import CoreData
import EventKit

class Workout {
    var workoutId: String
    var exercises: [Exercise]
    var exercisesWithWarmups: [Exercise]
    var date: Date
    
    init(exercises:[Exercise], workoutId: String, moc: NSManagedObjectContext) {
        self.exercises = exercises.sorted(by: { $0.weight > $1.weight })
        self.workoutId = workoutId
        self.date = exercises[0].date
        self.exercisesWithWarmups = Workout.getExercisesWithWarmups(exercises: exercises, moc: moc)
        // save newly generated warmup exercises
        do {
            try moc.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    };
    
    static func generateWarmupsForExercise(exercise: Exercise, moc: NSManagedObjectContext) -> [Exercise] {
        var warmups: [Exercise] = []
        let warmupProportionsOfMaxAndRep = [
            0.1: 10,
            0.3: 10,
            0.5: 5,
            0.7: 3,
            0.8: 2
        ]
        
        for (proportion, reps) in warmupProportionsOfMaxAndRep {
            let warmup:Exercise = Exercise(context: moc)
            warmup.lift = exercise.lift
            warmup.sets = 1
            warmup.reps = Int16(reps)
            warmup.weight = exercise.weight * Float(proportion)
            warmup.workoutId = exercise.workoutId
            warmup.date = exercise.date
            warmup.day = exercise.day
            warmup.programId = exercise.programId
            warmups.append(warmup)
        }
        
        return warmups.sorted(by: { $0.weight < $1.weight })
    }
    
    
    static func getExercisesWithWarmups(exercises: [Exercise], moc: NSManagedObjectContext) -> [Exercise] {
        var exercisesWithWarmups: [Exercise] = []
        for exercise in exercises {
            if exercise.needsWarmups == true {
                let warmups = generateWarmupsForExercise(exercise: exercise, moc: moc)
                exercisesWithWarmups += warmups
            }
            exercisesWithWarmups.append(exercise)
        }
        
        return exercisesWithWarmups
    }
    
    func getMainLift() -> String {
        return self.exercises[0].lift
    }
    
    func workoutDescriptionHelper(exercises: [Exercise]) -> String {
        let mainLift = getMainLift()
        var description = String(mainLift + " day!\n")
        for exercise in exercises {
            description += exercise.getExerciseDescription() + "\n"
        }
        description += ("View on swoleymoley://view_workout?" + self.workoutId)
        return description
    }
    
    func getWorkoutDescription() -> String {
        return workoutDescriptionHelper(exercises: self.exercisesWithWarmups)
    }
    
    func getWorkoutDescriptionWithouWarmups() -> String {
        return workoutDescriptionHelper(exercises: self.exercises)
    }
    
    func getLifts() -> String {
        var lifts: Set<String> = []
        for exercise in self.exercises {
            lifts.insert(exercise.lift)
        }
        return lifts.joined(separator:", ")
        
    }
    
}


func addWorkoutsToCalendar(workouts: [Workout], completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
    let eventStore = EKEventStore()

    eventStore.requestAccess(to: .event, completion: { (granted, error) in
        if (granted) && (error == nil) {
            for workout in workouts {
                let event = EKEvent(eventStore: eventStore)
                event.title = "SwoleyMoley Workout: " + workout.getLifts()
                event.startDate = workout.date
                event.endDate = workout.date
                event.notes = workout.getWorkoutDescriptionWithouWarmups()
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(event, span: .thisEvent)
                } catch let e as NSError {
                    completion?(false, e)
                    return
                }
                completion?(true, nil)
            }
        } else {
            completion?(false, error as NSError?)
        }
    })
}
