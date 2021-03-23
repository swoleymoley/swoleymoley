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

//csv stuff should be split into its own file
class Workout {
    var day: Int
    var reps: Int
    var sets: Int
    var fractionOfMax: Float
    var lift: String
    var weekNumber: Int
    var weight: Float
    
    init(day: Int, reps: Int, sets: Int, fractionOfMax: Float, lift: String, weekNumber: Int, weight: Float) {
        self.day = day
        self.reps = reps
        self.sets = sets
        self.fractionOfMax = fractionOfMax
        self.lift = lift
        self.weekNumber = weekNumber
        self.weight = weight
    }
   
}

var workouts = [Workout]()

func convertCSVIntoArray() {
        //locate the file you want to use
        guard let filepath = Bundle.main.path(forResource: "power_lift_template", ofType: "csv") else {
            return
        }
        //convert that file into one long string
        var data = ""
        do {
            data = try String(contentsOfFile: filepath)
        } catch {
            print(error)
            return
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
                let day = Int(columns[0]) ?? 0
                let reps = Int(columns[1]) ?? 0
                let sets = Int(columns[2]) ?? 0
                let fractionOfMax = Float(columns[3]) ?? 0
                let lift = columns[4]
                let weekNumber = Int(columns[5]) ?? 0

                let workout = Workout(day: day, reps: reps, sets: sets, fractionOfMax: fractionOfMax, lift: lift, weekNumber: weekNumber, weight: 0.0 )
                workouts.append(workout)
            }
        }
    }

struct Maxes {
    var bench: Float
    var deadLift: Float
    var squat: Float
    
    var dictionary: [String: Float] {
        return ["bench": bench,
                "deadLift": deadLift,
                "squat": squat]
        }
}

func calculateWorkoutWeights(workouts: [Workout], maxes: Maxes) -> [Workout] {
    let maxesDict = maxes.dictionary
    for workout in workouts {
        if workout.lift != "meet" {
            workout.weight = workout.fractionOfMax * maxesDict[workout.lift]!
        }
    }
    return workouts
}

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
                print(result)
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
                Text("Result:")
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



