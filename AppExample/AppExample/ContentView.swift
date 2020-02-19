//
//  ContentView.swift
//  AppExample
//
//  Created by Lyndsey Ferguson on 2/17/20.
//  Copyright © 2020 Lyndsey Ferguson. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text(self.text)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(self.backgroundColor)
    }
    
    var text: String {
        return configuration?["WelcomeMessage"] as! String
    }
    
    var backgroundColor: Color {
        if let colorString: String = self.configuration?["BackgroundHexColor"] as? String {
            if let color = UIColor(hex: colorString) {
                return Color(color)
            }
        }
        return  Color.white
    }
    
    var configuration: NSDictionary? {
        var nsDictionary: NSDictionary?
        if let path = Bundle.main.path(forResource: "configurations", ofType: "plist") {
           nsDictionary = NSDictionary(contentsOfFile: path)
        }
        return nsDictionary
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
