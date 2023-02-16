//
//  RssItem.swift
//  RSSClient
//
//  Created by Mark Heijnekamp on 12/02/2023.
//

import Foundation

struct RssItem: Identifiable{
    let id = UUID()
    var title:String
    var description:String
    var Image:String?
    
    init(title: String, description: String) {
        self.title = title
        self.description = description
    }
}
