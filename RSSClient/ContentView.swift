//
//  ContentView.swift
//  RSSClient
//
//  Created by Mark Heijnekamp on 12/02/2023.
//

import SwiftUI

struct ContentView: View {
    @State var store: RssStore = RssStore(RssArray: [RSS(url: URL(string: "https://feeds.nos.nl/nosnieuwsalgemeen")!, updatedAt: Date(), createdAt: Date())])
    @State var updated_At: Date = Date()
    @State var news: [RssItem] = []
    @State var Selected: RSS?;
    
    init() {
        print("Start")
        store.addRss(Rss: RSS(url: URL(string: "https://feeds.nos.nl/nosnieuwsalgemeen")!, updatedAt: Date(), createdAt: Date()))
        self.store.num+=1
    }
    
    var body: some View {
        Text(String(store.num))
        NavigationSplitView{
            List(store.rssArray, selection: $Selected) { item in
                NavigationLink(item.getName(), value: item)
            }.buttonStyle(BorderlessButtonStyle())

        }
        detail:{
            if(Selected != nil){
                Text(Selected!.getName())
                Text(String(Selected!.done))
                List(news){item in
                    Text(item.title)
                }
            }
        }
        .onChange(of: Selected){ newvalue in
            if(newvalue!.body == nil || newvalue?.body.count == 0){
                newvalue!.fetch(){data in
                    news = data!
                }
            }
            else{
                news = newvalue!.body
            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
