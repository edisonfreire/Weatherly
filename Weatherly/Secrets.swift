//
//  Secrets.swift
//  Weatherly
//
//  Created by Edison Freire on 4/30/25.
//

import Foundation

enum Secrets {
    static var apiKey: String {
        guard let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist") else {
            fatalError("Couldn't find file 'Secrets.plist'. Make sure it's added to the target.")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "API_KEY") as? String else {
            fatalError("Couldn't find key 'API_KEY' in 'Secrets.plist' or it's not a String.")
        }
        if value.starts(with: "YOUR_") || value.isEmpty {
            fatalError("API Key in 'Secrets.plist' seems to be a placeholder or empty. Please replace it with your actual key.")
        }
        return value
    }
}
