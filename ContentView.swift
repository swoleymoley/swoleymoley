//
//  ContentView.swift
//  SwoleyMoleyDatePickerBranch
//
//  Created by Kresimir Tokic on 4/7/21.
//

import SwiftUI

struct ContentView: View {
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()

    @State private var meetDate = Date()

    var body: some View {
        VStack {
            Text("Select meet date").font(.largeTitle)
            
           // DatePicker(selection: $meetDate, in: Date()..., displayedComponents: .date) {}
            
            DatePicker("Enter Meet Date", selection: $meetDate, in: Date()..., displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .frame(maxHeight: 400)

            Text("Selected Date is \(meetDate, formatter: dateFormatter)")
            
        }
    }
}
