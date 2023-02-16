//
//  RssStore.swift
//  RSSClient
//
//  Created by Mark Heijnekamp on 13/02/2023.
//

import Foundation

class RssStore: NSObject, ObservableObject{
   @Published public var num = 0;
    @Published var rssArray:[RSS] = []{
        didSet{
            print("RssArray diid update")
        }
        willSet{
            print("RssArray will set")
        }
    }
    
    init(RssArray: [RSS]) {
        self.rssArray = RssArray
    }
   convenience override init(){
        self.init(RssArray: [])
    }
    
    func addRss(Rss:RSS){
        rssArray.append(Rss)
        num += 1
    }
//    func addRss(Rss: RSS) {
//        print("addRss called")
//        var updatedRss = Rss
//        self.rssArray = self.rssArray.filter { $0.url != updatedRss.url }
//        self.rssArray.append(updatedRss)
//    }

    
    func getNames() -> [String]{
        var names:[String] = []
        rssArray.forEach{ Rss in
            names.append(Rss.getName())
        }
        return names
    }
    
    func getData(url: URL) -> RSS?{
        for RssI in rssArray{
            if(RssI.url == url){
                return RssI
            }
        }
        return nil
    }
    func getDataID(id:UUID) -> RSS?{
        for RssI in rssArray{
            if(RssI.id == id){
                return RssI
            }
        }
        return nil
    }
}
