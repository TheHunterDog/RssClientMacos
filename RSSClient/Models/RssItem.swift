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
    var Link:URL?
    var publishDate:String
    
    init(title: String, description: String) {
        self.init(title: title, description: description, publishDate: "", Link: URL(string: ""),Image:"")
    }
    init(title:String,description: String,publishDate:String , Link:URL?, Image:String){
        self.title = title
        self.description = description
        self.publishDate = publishDate
        self.Link = Link
        self.Image = Image
    }
}
