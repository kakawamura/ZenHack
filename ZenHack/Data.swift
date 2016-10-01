//
//  Data.swift
//  ZenHack
//
//  Created by KazushiKawamura on 10/2/16.
//  Copyright © 2016 KazushiKawamura. All rights reserved.
//


import ObjectMapper

// Entity Class

class Data: Mappable {
    var name: String?
    var image: String?
    var thumbnail: String?
    
    required init?(_ map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        name <- map["name"]
        image <- map["image"]
        thumbnail <- map["thumbnail"]
    }
}