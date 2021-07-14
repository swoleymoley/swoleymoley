//
//  ContentView.swift
//  FrontEndTest
//
//  Created by Kresimir Tokic on 2/21/21.
//
// reference tutorials:
// https://sarunw.com/posts/textfield-in-swiftui/
//https://www.appcoda.com/swiftui-buttons/
//

import SwiftUI
import Foundation
import EventKit
import CoreData


func convertTemplateCSVIntoArrayOfExercises(maxes: Maxes, startDate: Date, moc: NSManagedObjectContext)  -> [Exercise] {
    var exercises = [Exercise]()
    let programId = UUID().uuidString
    let maxesDict = maxes.dictionary
        //locate the file you want to use
        guard let filepath = Bundle.main.path(forResource: "power_lift_template", ofType: "csv") else {
            return exercises
        }
        //convert file into one long string
        var data = ""
        do {
            data = try String(contentsOfFile: filepath)
        } catch {
            print(error)
            return exercises
        }
        //string into an array of "rows" of data.  Each row is a string.
        var rows = data.components(separatedBy: .newlines)
    
        //remove header row
        rows.removeFirst()
        //now loop around each row, and split it into each of its columns
        for row in rows {
            let columns = row.components(separatedBy: ",")

            //check that we have enough columns
            if columns.count == 7 {
                let day = Int16(columns[0]) ?? 0
                let reps = Int16(columns[1]) ?? 0
                let sets = Int16(columns[2]) ?? 0
                let fractionOfMax = Float(columns[3]) ?? 0
                let lift = columns[4]
                let weekNumber = Int16(columns[5]) ?? 0
                let needsWarmups = Bool(columns[6]) ?? true

                let exercise = Exercise(context: moc)
                exercise.programId = programId
                exercise.workoutId = programId + String(day)
                exercise.day = day
                exercise.reps = reps
                exercise.sets = sets
                exercise.fractionOfMax = fractionOfMax
                exercise.lift = lift
                exercise.weekNumber = weekNumber
                exercise.needsWarmups = needsWarmups
                exercise.setExerciseDate(startDate: startDate)
                exercise.setExerciseWeight(maxesDict: maxesDict)
                //workout.addWorkoutToCalendar()
                exercises.append(exercise)
            }
            // save newly created exercise objects
            do {
                try moc.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        }
    return exercises
    }


func getWorkoutsFromExercises(exercises: [Exercise], moc: NSManagedObjectContext) -> [Workout] {
    var exercisesByExerciseId: [String:[Exercise]] = [:]
    var workouts: [Workout] = []
    for exercise in exercises {
        if exercisesByExerciseId.keys.contains(exercise.workoutId){
            exercisesByExerciseId[exercise.workoutId]!.append(exercise)
        }
        else {
            exercisesByExerciseId[exercise.workoutId] = [exercise]
        }
    }
    for (workoutId, array_of_exercises) in exercisesByExerciseId{
        let workout = Workout(exercises: array_of_exercises, workoutId: workoutId, moc: moc)
        workout.getExercisesWithWarmups()
        workouts.append(workout)
    }
    return workouts
        
}

func fetchExercisesFromCoreData(moc: NSManagedObjectContext)  -> [Exercise] {
    let exercisesFetch = Exercise.createFetchRequest()

    do {
        let fetchedExercises = try moc.fetch(exercisesFetch)
        return fetchedExercises
    } catch {
        fatalError("Failed to fetch exercises: \(error)")
    }
}

func fetchExercisesFromCoreDataByworkoutId(moc: NSManagedObjectContext, workoutId: String)  -> [Exercise]? {
    let exercisesFetch = Exercise.createFetchRequest()
    exercisesFetch.predicate = NSPredicate(format: "workoutId == %@", workoutId)
    do {
        let fetchedExercises = try moc.fetch(exercisesFetch)
        if fetchedExercises.isEmpty {
            return nil
        } else {
        return fetchedExercises
        }
    } catch {
        fatalError("Failed to fetch exercises: \(error)")
    }
}


func fetchExercisesFromURLQuery(moc: NSManagedObjectContext, url: URL) -> [Exercise]? {
    let exercises = fetchExercisesFromCoreDataByworkoutId(
        moc: moc,
        workoutId: url.query ?? "none"
    ) ?? nil
    return exercises
}

struct Maxes {
    var bench: Float
    var deadLift: Float
    var squat: Float
    var frontSquat: Float
    var dip: Float
    var pullUp: Float
    
    var dictionary: [String: Float] {
        return ["bench": bench,
                "deadLift": deadLift,
                "squat": squat,
                "frontSquat": frontSquat,
                "dip": dip,
                "pullUp": pullUp,
                "none": 0.0
        ]
        }
}

    
//this function just styles the textfield
struct SuperCustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .padding()
            .border(Color.accentColor)
    }
}


struct ProgramBuilderView: View {
    //these are the variables hodling user input
    //im unsure how to make these global or accessible out this scope
    @State private var bench_max = ""
    @State private var squat_max = ""
    @State private var deadlift_max = ""
    @State private var result = ""
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.managedObjectContext) var managedObjectContext
    //declares a view
    var body: some View {
        HStack{
            Text("How much you lift bro?")
            Text("")
        }
        VStack{ //vertical stacking elements
            HStack{ //horiz stack of first two elements
                Text("Bench Max (lbs):")
        //textfield monitors user input live to debug console
                TextField("enter you Bench Max", text: $bench_max,onEditingChanged: { (isBegin) in
            if isBegin {
                print("Begins editing")
            } else {
                print("Finishes editing")
                
            }
        },
        onCommit: {
            print("commit")
        }).textFieldStyle(SuperCustomTextFieldStyle())
            }
        
            HStack{
                Text("Squat Max (lbs):")
            
                TextField("enter you Squat Max", text: $squat_max, onCommit:{print("squat max commited: " + squat_max)}).textFieldStyle(RoundedBorderTextFieldStyle())
                
            }
            
            HStack{
                Text("Deadlift Max (lbs):")
            //different style for demo
            TextField("enter your Deadlift Max", text: $deadlift_max).textFieldStyle(RoundedBorderTextFieldStyle())
            }
            //heres to code for the calc button
            Button(action: {
                // What to perform
                print("I've been tapped")
                let maxes = Maxes(
                    bench: Float(bench_max) ?? 0.0,
                    deadLift: Float(deadlift_max) ?? 0.0,
                    squat: Float(squat_max) ?? 0.0,
                    frontSquat: 0.7 * (Float(squat_max) ?? 0.0),
                    dip: 0.5 * (Float(bench_max) ?? 0.0),
                    pullUp: 0.5 * (Float(bench_max) ?? 0.0)
                )
                
                // delete once we have a date picker
                let startDate = Date()
                
                var exercises = convertTemplateCSVIntoArrayOfExercises(
                    maxes: maxes,
                    startDate: startDate,
                    moc: managedObjectContext
                )
                var workouts = getWorkoutsFromExercises(exercises: exercises, moc: managedObjectContext)
                //workouts[0].saveTCX()
                // if we want to fetch saved workouts use this!
                //var workouts = fetchWorkoutsFromCoreData(moc: managedObjectContext)
                
                //if we want to fetch a workout by its id use this
                //let workout = fetchWorkoutFromCoreDataByWorkoutId(moc: managedObjectContext, workoutId: "98187587-E8F0-418D-A41C-ADCAF03DB8E1")
        
                addWorkoutsToCalendar(workouts: workouts)
                for workout in workouts{
                    print(workout.date, workout.getWorkoutDescription())
                }
                result = "Program generated! Check that Calendar"
            }) {
                // How the button looks like
                // the order of modifiers is important
                Text("Calculate")
                    .fontWeight(.bold)
                    .font(.title)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(40)
                    .foregroundColor(.white)
                    .padding(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 40)
                            .stroke(Color.red, lineWidth: 5)
                    )
            }
            
            HStack{
                Text(result)
            }
            
        }
    }
}


struct SingleWorkoutView: View {
    let launchURL: URL
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var body: some View {
        
        let exercises = fetchExercisesFromURLQuery(
            moc: managedObjectContext,
            url: launchURL
        )
        
        let workout = Workout(
                exercises: exercises ?? [Exercise()],
                workoutId: exercises?[0].workoutId ?? "No Exercise",
                moc: managedObjectContext
            )
        List {
                VStack{
                Text(launchURL.absoluteString)
                Text("")
                Text(workout.getWorkoutDescription())
            }
            Button(action: {
                // What to perform
                print("I've been tapped")
                //workout.postToStrava()
                
            }) {
                // How the button looks like
                // the order of modifiers is important
                Text("Push to Strava")
                    .fontWeight(.bold)
                    .font(.title)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(40)
                    .foregroundColor(.white)
                    .padding(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 40)
                            .stroke(Color.red, lineWidth: 5)
                    )
            }
    }
    }
}


struct SingleWorkoutNavigationView: View {
    let launchURL: URL
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var body: some View {
        NavigationView {
                    let exercises = fetchExercisesFromURLQuery(
                        moc: managedObjectContext,
                        url: launchURL
                    )
                    
                    let workout = Workout(
                            exercises: exercises ?? [Exercise()],
                            workoutId: exercises?[0].workoutId ?? "No Exercise",
                            moc: managedObjectContext
                        )
                    VStack {
                        Text("Navigation view")
                        NavigationLink(destination: workout.postToStrava()) {
                            Text("Push to Strava")
                        }
        
                    }
            
        }
}
}

//this is where its happening
struct ContentView: View {
    @Binding var launchURL: URL
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.managedObjectContext) var managedObjectContext
    //declares a view
    var body: some View {
        if launchURL.absoluteString.contains("view_workout"){
            SingleWorkoutNavigationView(launchURL: launchURL)
        } else {
            ProgramBuilderView()
        }
    }
}


//this is the previewer code
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(launchURL: .constant(URL(fileURLWithPath: "https://exampleplaceholder.com")))
    }
}



