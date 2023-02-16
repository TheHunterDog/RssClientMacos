//
//  RSS.swift
//  RSSClient
//
//  Created by Mark Heijnekamp on 12/02/2023.
//

import Foundation
import Combine
import Network

class RSS:NSObject ,Identifiable,ObservableObject {
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
    let monitor = NWPathMonitor()
    
    init(url: URL, updatedAt: Date, createdAt: Date, Name: String) {
        self.url = url
        self.updatedAt = updatedAt
        self.createdAt = createdAt
        self.name = Name
    }
    
    convenience init(url: URL, updatedAt: Date, createdAt: Date) {
        self.init(url: url, updatedAt: updatedAt, createdAt: createdAt, Name: url.host() ?? "Unknown")
    }

    // Conforming to ObservableObject requires a class-level objectWillChange Publisher
//    let objectWillChange = ObservableObjectPublisher()
    
    func fetch(completion: @escaping ([RssItem]?) -> Void) {
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
        } else {
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
            body.append(RssItem(title: self.xmlDict["title"] as! String, description: self.xmlDict["description"] as! String))
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
