//
//  ContentView.swift
//  TouchChaserExample
//
//  Created by Casper Zandbergen on 28/01/2021.
//

import SwiftUI
import TouchChaser

struct ContentView: View {
    var body: some View {
        VStack {
            Text("TouchChaser")
                .font(.title)
                .bold()
                .padding(.top, 50)
            Text("by Amzd")
                .font(.subheadline)
                .opacity(0.6)
                .padding(.top, 5)
            Spacer()
        }.addTouchChaser(.always)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
