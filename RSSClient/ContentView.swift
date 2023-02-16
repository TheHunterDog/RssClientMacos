//
//  ContentView.swift
//  RSSClient
//
//  Created by Mark Heijnekamp on 12/02/2023.
//

import SwiftUI
import WebKit

struct ContentView: View {
    @StateObject var store: RssStore = RssStore(RssArray: [RSS(url: URL(string: "https://feeds.nos.nl/nosnieuwsalgemeen")!, updatedAt: Date(), createdAt: Date())])
    @State var updated_At: Date = Date()
    @State var news: [RssItem] = []
    @State var Selected: RSS? ;
    @State var sel: Bool = false
    
    init() {
        print("Start")
        store.addRss(Rss: RSS(url: URL(string: "https://feeds.nos.nl/nosnieuwsalgemeen")!, updatedAt: Date(), createdAt: Date()))
        self.store.num+=1
    }
    

    var body: some View {
//        Text(String(store.num))
        NavigationSplitView{
            List(store.rssArray, selection: $Selected) { item in
                NavigationLink(item.getName(), value: item)
            }.buttonStyle(BorderlessButtonStyle())
            
        }
    detail:{
        if let select = Selected {
//            Text(select.getName())
//            Text(String(select.done))
            List(news){item in
                Text(item.title)
                //                    Text(item.description)
//                HTMLView(htmlString: item.description)
//                    .frame(minWidth: 0, idealWidth: 300, maxWidth: .infinity, minHeight: 0, idealHeight: 300, maxHeight: .infinity)
//                    .padding()
                Text(item.description)
            }
            Spacer()
        }
    }
    .onChange(of: Selected){ newvalue in
        if let selected = newvalue {
            if selected.body.isEmpty {
                selected.fetch(){data in
                    news = data!
                }
            } else {
                news = selected.body
            }
        }
        
    }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
