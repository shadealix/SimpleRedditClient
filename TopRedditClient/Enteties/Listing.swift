//
//  Listing.swift
//  TopRedditClient
//
//  Created by Alix on 1/24/21.
//

import Foundation


enum Kind: String, Codable {
    case listing = "Listing"
}

struct Listing: Codable {
    let kind: Kind
    let listingInfo: ListingInfo
    
    enum CodingKeys: String, CodingKey {
        case kind
        case listingInfo = "data"
    }
}

struct Child: Codable {
    let data: ChildData
}

struct ChildData: Codable {
    let title: String
    let author: String
    let thumbnail: String
    let thumbnailHeight: Int?
    let thumbnailWidth: Int?
    let commentsCount: Int
    let created: Date
    let preview: Preview?
    
    enum CodingKeys: String, CodingKey {
        case title
        case author
        case thumbnail
        case thumbnailHeight = "thumbnail_height"
        case thumbnailWidth = "thumbnail_width"
        case commentsCount = "num_comments"
        case created
        case preview
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        author = try container.decode(String.self, forKey: .author)
        thumbnail = try container.decode(String.self, forKey: .thumbnail)
        thumbnailHeight = try container.decode(Int?.self, forKey: .thumbnailHeight)
        thumbnailWidth = try container.decode(Int?.self, forKey: .thumbnailWidth)
        commentsCount = try container.decode(Int.self, forKey: .commentsCount)
        preview = try? container.decode(Preview?.self, forKey: .preview)
        let timeInterval = try container.decode(TimeInterval.self, forKey: .created)
        created = Date(timeIntervalSince1970: timeInterval)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(author, forKey: .author)
        try container.encode(thumbnail, forKey: .thumbnail)
        try container.encode(thumbnailHeight, forKey: .thumbnailHeight)
        try container.encode(thumbnailHeight, forKey: .thumbnailWidth)
        try container.encode(commentsCount, forKey: .commentsCount)
        try container.encode(preview, forKey: .preview)
        try container.encode(created.timeIntervalSince1970, forKey: .created)
    }
}

struct ListingInfo: Codable {
    let children: [Child]
    let after: String?
    let before: String?
}

struct Preview: Codable {
    struct Image: Codable {
        let source: Source
    }
    
    struct Source: Codable {
        let url: String
        let width: Int
        let height: Int
    }
    
    let images: [Image]
    let enabled: Bool
}
