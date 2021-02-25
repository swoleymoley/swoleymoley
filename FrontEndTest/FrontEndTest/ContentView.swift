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
    @State private var weight = ""
    @State private var reps = ""
    @State private var sets = ""
    @State private var result = ""
    
    //declares a view
    var body: some View {
        VStack{ //vertical stacking elements
            HStack{ //horiz stack of first two elements
                Text("Weight:")
        //textfield monitors user input live to debug console
                TextField("enter weight", text: $weight,onEditingChanged: { (isBegin) in
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
                Text("Reps:")
            
                TextField("enter reps", text: $reps, onCommit:{print("reps commited: " + reps)}).textFieldStyle(RoundedBorderTextFieldStyle())
                
            }
            
            HStack{
                Text("Sets:")
            //different style for demo
            TextField("enter sets", text: $sets).textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            //heres to code for the calc button
            Button(action: {
                // What to perform
                print("I've been tapped")
                //this is probably where you'll have grab the user input
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



