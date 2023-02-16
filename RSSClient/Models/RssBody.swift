//
//  RssBody.swift
//  RSSClient
//
//  Created by Mark Heijnekamp on 12/02/2023.
//

import Foundation

class RssBody :NSObject, ObservableObject{
    @Published var items: [RssItem];
    override init(){
        items = []
    }
    init(items: [RssItem]) {
        self.items = items
        
    }
    
}
