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



