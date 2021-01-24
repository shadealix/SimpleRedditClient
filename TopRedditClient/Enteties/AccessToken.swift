//
//  AccessToken.swift
//  TopRedditClient
//
//  Created by Alix on 1/24/21.
//

import Foundation

struct AccessTokenResponse: Codable {
    let accessToken: String
    let type: String
    let deviceID: String
    let expiresIn: Int
    let scope: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case type = "token_type"
        case deviceID = "device_id"
        case expiresIn = "expires_in"
        case scope
    }
}

struct AccessToken {
    let token: String
    let expirationDate: Date?
    
    var isValid: Bool {
        guard let expiration = expirationDate else { return false }
        
        return expiration > Date()
    }
    
    init(token: String, expiresIn: Int) {
        self.token = token
        self.expirationDate = Calendar.current.date(byAdding: .second, value: expiresIn, to: Date())
    }
}
