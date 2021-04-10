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


//csv stuff should be split into its own file
class Workout {
    var day: Int
    var reps: Int
    var sets: Int
    var fractionOfMax: Float
    var lift: String
    var weekNumber: Int
    var weight: Float
    var date: Date
    
    init(day: Int, reps: Int, sets: Int, fractionOfMax: Float, lift: String, weekNumber: Int, weight: Float, date: Date) {
        self.day = day
        self.reps = reps
        self.sets = sets
        self.fractionOfMax = fractionOfMax
        self.lift = lift
        self.weekNumber = weekNumber
        self.weight = weight
        self.date = date
    }
    
    func setWorkoutWeight(maxesDict: [String: Float]) {
        if self.lift != "meet" {
            self.weight = self.fractionOfMax * maxesDict[self.lift]!
        }
    }

    func setWorkoutDate(startDate: Date) {
        var dayComponent = DateComponents()
        dayComponent.day = self.day
        let theCalendar = Calendar.current
        self.date = theCalendar.date(byAdding: dayComponent, to: startDate)!
    }
    
    func getWorkoutDescription() -> String{
        return self.lift + " day!\n" + String(self.weight) + " lbs for " + String(self.sets) + " sets of " + String(self.reps) + " reps\n View on swoleymoley://open"
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

func addWorkoutsToCalendar(workouts: [Workout], completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
    let eventStore = EKEventStore()

    eventStore.requestAccess(to: .event, completion: { (granted, error) in
        if (granted) && (error == nil) {
            for workout in workouts {
                let event = EKEvent(eventStore: eventStore)
                event.title = "SwoleyMoley Workout: " + workout.lift
                event.startDate = workout.date
                event.endDate = workout.date
                event.notes = workout.getWorkoutDescription()
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

func convertTemplateCSVIntoArrayOfWorkouts(maxes: Maxes, startDate: Date, moc: NSManagedObjectContext)  -> [Dorkout] {
    var workouts = [Dorkout]()
    let program_id = UUID().uuidString
    let maxesDict = maxes.dictionary
        //locate the file you want to use
        guard let filepath = Bundle.main.path(forResource: "power_lift_template", ofType: "csv") else {
            return workouts
        }
        //convert that file into one long string
        var data = ""
        do {
            data = try String(contentsOfFile: filepath)
        } catch {
            print(error)
            return workouts
        }
        //now split that string into an array of "rows" of data.  Each row is a string.
        var rows = data.components(separatedBy: .newlines)
        
        //if you have a header row, remove it here
        rows.removeFirst()
        //now loop around each row, and split it into each of its columns
        for row in rows {
            let columns = row.components(separatedBy: ",")

            //check that we have enough columns
            if columns.count == 6 {
                let day = Int16(columns[0]) ?? 0
                let reps = Int16(columns[1]) ?? 0
                let sets = Int16(columns[2]) ?? 0
                let fractionOfMax = Float(columns[3]) ?? 0
                let lift = columns[4]
                let weekNumber = Int16(columns[5]) ?? 0

                let workout = Dorkout(context: moc)
                workout.program_id = program_id
                workout.workout_id = UUID().uuidString
                workout.day = day
                workout.reps = reps
                workout.sets = sets
                workout.fractionOfMax = fractionOfMax
                workout.lift = lift
                workout.weekNumber = weekNumber
                workout.setWorkoutDate(startDate: startDate)
                workout.setWorkoutWeight(maxesDict: maxesDict)
                //workout.addWorkoutToCalendar()
                workouts.append(workout)
            }
        }
    return workouts
    }

struct Maxes {
    var bench: Float
    var deadLift: Float
    var squat: Float
    
    var dictionary: [String: Float] {
        return ["bench": bench,
                "deadLift": deadLift,
                "squat": squat,
                "none": 0.0
        ]
        }
}

//func calculateWorkoutWeight(workouts: [Workout], maxes: Maxes) -> [Workout] {
//    let maxesDict = maxes.dictionary
//    for workout in workouts {
//        if workout.lift != "meet" {
//            workout.weight = workout.fractionOfMax * maxesDict[workout.lift]!
//        }
//    }
//    return workouts
//}


    
//this function just styles the textfield
struct SuperCustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .padding()
            .border(Color.accentColor)
    }
}



//this is where its happening
struct ContentView: View {
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
                result = String(Int(bench_max)! + Int(squat_max)! + Int(deadlift_max)!)
                let maxes = Maxes(bench: Float(bench_max)!, deadLift: Float(deadlift_max)!, squat: Float(squat_max)!)
                
                // delete once we have a date picker
                let startDate = Date()
                
                var workouts = convertTemplateCSVIntoArrayOfWorkouts(
                    maxes: maxes,
                    startDate: startDate,
                    moc: managedObjectContext
                )
                //addWorkoutsToCalendar(workouts: workouts)
                for workout in workouts{
                    print(workout.day, workout.lift, workout.weight, workout.day, workout.date)
                }
                result = "Workout generated! Check that Calendar"
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


//this is the previewer code
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



