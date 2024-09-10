//
//  Music.swift
//  MusicAPI
//
//  Created by 坂下雄哉 on 2024/09/10.
//

import Foundation

struct MusicResponse: Codable{
    var results: [Music]
}
struct Music: Codable{
    var trackName: String
    var artworkUrl160: URL
}
