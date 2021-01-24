//
//  KeyManager.swift
//  TopRedditClient
//
//  Created by Alix on 1/24/21.
//

import Foundation


enum Key: String {
    case redditAppKey = "redditAppKey"
}

final class KeysInfoManager {
    
    static func productFor(named keyname: Key) -> String {
        
        guard let filePath = Bundle.main.path(forResource: "ApiKeys", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath) else {
            return ""
        }
        
        let value = plist.object(forKey: keyname.rawValue) as? String
        return value ?? ""
    }

}
