//
//  RSS.swift
//  RSSClient
//
//  Created by Mark Heijnekamp on 12/02/2023.
//

import Foundation
import Combine
import Network

class RSS:NSObject ,Identifiable,ObservableObject,Encodable,Decodable {
    let id = UUID()
    var url: URL;
    var name: String?;
    var updatedAt: Date;
    var createdAt: Date;
    @Published var body: [RssItem] = []{
        didSet{
            print("body Updated")
            objectWillChange.send()
        }
    }
    var xmlDict = [String: Any]()
    var xmlDictArr = [[String: Any]]()
    var currentElement = ""
    @Published var done = false;
    var HasConnection = false;
    let monitor = NWPathMonitor(requiredInterfaceType: .wifi)
    let queue = DispatchQueue.global(qos: .background)
    
    enum CodeKeys: CodingKey
    {
         case url
         case name
    }

    func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodeKeys.self)
        try container.encode (url, forKey: .url)
        try container.encode (name, forKey: .name)
    }
    required init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodeKeys.self)
        url = try values.decode(URL.self, forKey: .url)
        name = try values.decode(String.self, forKey: .name)
        updatedAt = Date()
        createdAt = Date()
    }
    func clearCache(){
        self.body = []
    }
    init(url: URL, updatedAt: Date, createdAt: Date, Name: String) {
        self.url = url
        self.updatedAt = updatedAt
        self.createdAt = createdAt
        self.name = Name
    }
    
    convenience init(url: URL, updatedAt: Date, createdAt: Date) {
        self.init(url: url, updatedAt: updatedAt, createdAt: createdAt, Name: url.host ?? "Unknown")
    }
    func setupMonitor(){
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [self] path in
            if path.status == .satisfied {
                print("Connected")
                HasConnection = true
            }
            else if(path.status == .unsatisfied){
                print("NO ACCESS")
                HasConnection = false
            }
        }
    }
    // Conforming to ObservableObject requires a class-level objectWillChange Publisher
//    let objectWillChange = ObservableObjectPublisher()
    
    func fetch(completion: @escaping ([RssItem]?) -> Void) {
        //TODO: Move monitor
        self.setupMonitor()
        if(!HasConnection)
        {
            completion([RssItem(title: "[BREAKING] No internet", description: "*Breaking news*: You got no internet access")])
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let _ = String(data: data, encoding: .utf8) {
                let parser = XMLParser(data: data)
                parser.delegate = self
                parser.parse()
                self.updatedAt = Date()
                completion(self.body)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    func fetchData(for rss: RSS) {
        rss.fetch { result in
            DispatchQueue.main.async {
                if let result = result {
                    rss.body = result
                }
                rss.done = true
            }
        }
    }

    
    func getName() -> String {
        return name!
    }
}

extension RSS: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        if elementName == "item" {
            xmlDict = [:]
        }
        if elementName == "enclosure"{
            xmlDict["enclosure"] = attributeDict["url"]
        }else {
            currentElement = elementName
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            if xmlDict[currentElement] == nil {
                xmlDict.updateValue(string, forKey: currentElement)
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            body.append(RssItem(title: self.xmlDict["title"] as! String, description: self.xmlDict["description"] as? String ?? "No description present", publishDate: self.xmlDict["pubDate"] as! String, Link:URL(string: self.xmlDict["link"]! as! String)!, Image: self.xmlDict["enclosure"] as? String ?? ""))
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        parsingCompleted()
    }
    
    func parsingCompleted() {
        done = true
        objectWillChange.send()
        print("done")
    }
}
