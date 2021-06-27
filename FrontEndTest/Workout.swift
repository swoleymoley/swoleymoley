//
//  Workout.swift
//  FrontEndTest
//
//  Created by Jeff Halley on 4/24/21.
//

import Foundation
import CoreData
import EventKit
import TCXZpot_Swift

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
    
    func saveTCX(){
        let calendar = Calendar.current
        let day = calendar.component(.day, from: self.date)
        let month = calendar.component(.month, from: self.date)
        let year = calendar.component(.year, from: self.date)
        let hour = calendar.component(.hour, from: self.date)
        let minute = calendar.component(.minute, from: self.date)
        let timeWorkedOut = Double(self.exercises.count) * 1200
        let caloriesBurned = Int((timeWorkedOut / 3600) * 200)
        let db = TrainingCenterDatabase(
                    activities:
                        Activities(
                            with:
                                Activity(
                                    id: TCXDate(day: day, month: month, year: year, hour: hour, minute: minute, second: 0)!,
                                    laps: [
                                            Lap(
                                                startTime: TCXDate(day: day, month: month, year: year, hour: hour, minute: minute, second: 0)!,
                                                totalTime: timeWorkedOut,
                                                distance: 0,
                                                calories: caloriesBurned,
                                                intensity: .active,
                                                triggerMethod: .manual,
                                                tracks: Track(with:
                                                                Trackpoint(
                                                                    time: TCXDate(day: day, month: month, year: year, hour: hour, minute: minute, second: 0)!,
                                                                    position: Position(latitude: 40.08556, longitude: 22.35861))
                                                            )
                                            )
                                    ],
                                    notes: Notes(text: self.getWorkoutDescription()),
                                    creator: Device(
                                                    name: "SwoleyMoley",
                                                    unitID: 1,
                                                    productID: 1234567,
                                                    version: Version(versionMajor: 1, versionMinor: 0)
                                            ),
                                    sport: .other
                                )
                        ),
                        author:
                            Application(name: "SwoleyMoley",
                                        build: Build(version: Version(versionMajor: 1, versionMinor: 0)),
                                        languageID: "en",
                                        partNumber: "123-45678-90"
                            )
                    )
        
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURL = documentDirectory.appendingPathComponent("file_name.txt")
            let serializer = FileSerializer()
            db.serialize(to: serializer)
            print("XXXXXX", fileURL)
            try serializer.save(toPath : fileURL.path)
        }
            catch {
                print("XXXXXX",  error)

                print(error)
        }

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
