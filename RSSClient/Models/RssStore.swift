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
    let defaults = UserDefaults.standard
    
    init(RssArray: [RSS]) {
        self.rssArray = RssArray
    }
    convenience override init(){
        self.init(RssArray: [])
        rssArray = fetchRss()
    }
    
    func addRss(Rss:RSS){
        rssArray.append(Rss)
        num += 1
        saveRss()
    }
    func clearCache(){
        for rss in rssArray{
            rss.clearCache()
        }
    }
    func fetchRss() -> [RSS]{
        if let data = UserDefaults.standard.data(forKey: "rssArray") {
            if(data != nil){
                do{
                    let data = try JSONDecoder().decode([RSS].self, from: data)
                    return data as! [RSS]
                }
                catch let error {
                            print("Error decoding: \(error)")
                            return []
                        }
               
            }
        }
        return []
    }
    func saveRss(){
        self.clearCache()
        do {
            let data = try JSONEncoder().encode(rssArray)
            UserDefaults.standard.set(data, forKey: "rssArray")
        } catch let error {
            print("Error encoding: \(error)")
        }

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
