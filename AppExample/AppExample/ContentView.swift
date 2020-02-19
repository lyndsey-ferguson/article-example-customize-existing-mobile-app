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
        return self.configuration?["WelcomeMessage"] as? String ?? "Welcome"
    }
    
    var backgroundColor: Color {
        let brandedBackgroundColor = self.configuration?["BackgroundHexColor"]
            .flatMap { $0 as? String }
            .flatMap(UIColor.init(hex:))
            .flatMap(Color.init)
        
        return brandedBackgroundColor ?? .white
    }
    
    var configuration: NSDictionary? {
        return Bundle.main.path(forResource: "configurations", ofType: "plist")
            .flatMap(NSDictionary.init(contentsOfFile:))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
