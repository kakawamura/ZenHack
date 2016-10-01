//
//  Data.swift
//  ZenHack
//
//  Created by KazushiKawamura on 10/2/16.
//  Copyright © 2016 KazushiKawamura. All rights reserved.
//


import ObjectMapper
import RxSwift

// Entity Class

class Data: Mappable {
    var word: String?
    var imgs: [String]?
    var thumbnails: [String]?
    
    required init?(_ map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        word <- map["word"]
        imgs <- map["imgs"]
        thumbnails <- map["thumbnails"]
    }
}