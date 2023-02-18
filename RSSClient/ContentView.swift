//
//  ContentView.swift
//  RSSClient
//
//  Created by Mark Heijnekamp on 12/02/2023.
//

import SwiftUI
import WebKit
import Network
struct ContentView: View {
    @StateObject var store: RssStore = RssStore()
    @State var updated_At: Date = Date()
    @State var news: [RssItem] = []
    @State var Selected: RSS? ;
    @State var connection: Bool = false
    @State var presentAlert: Bool = false
    @State var rssUrl:String = ""

    
    init() {
        print("Start")
//        store.addRss(Rss: RSS(url: URL(string: "https://feeds.nos.nl/nosnieuwsalgemeen")!, updatedAt: Date(), createdAt: Date()))
        self.store.num+=1
        
                
    }
    func addRss(){
        store.addRss(Rss: RSS(url: URL(string: "https://feeds.nos.nl/nosnieuwsalgemeen")!, updatedAt: Date(), createdAt: Date()))
    }
    

    var body: some View {
//        Text(String(store.num))
        NavigationSplitView{
            List(store.rssArray, selection: $Selected) { item in
                NavigationLink(item.getName(), value: item)
            }.toolbar{
                Button {
                    presentAlert = true
                } label: {
                    Image(systemName: "plus")
                }

            }.alert("Add an RSS feed", isPresented: $presentAlert, actions: {
                TextField("RssUrl", text: $rssUrl)

                
                Button("add", action: {
                    if(rssUrl.isEmpty){
                        return
                    }
                    if let url = URL(string: rssUrl) {
                        if(url.isFileURL || (url.host != nil && url.scheme != nil)){
                            store.addRss(Rss: RSS(url: url as URL, updatedAt: Date(), createdAt: Date()))
                        }
                    }
                })
                Button("Cancel", role: .cancel, action: {})
            }, message: {
                Text("Please enter your username and password.")
            })
            
        }
    detail:{
        if Selected != nil{
            if !news.isEmpty {
                List(news){item in
                    Text(item.title).bold()
                    Text(item.publishDate)
                    if let image = item.Image, !image.isEmpty{
                        AsyncImage(url: URL(string: image))
                    }
                    HTMLView(html: item.description)
                }
                Spacer()
                Divider()
            }
            else{
                ProgressView()
            }
        }
    }
    .onChange(of: Selected){ newvalue in
        if let selected = newvalue {
            news = []
            if selected.body.isEmpty || (Date().timeIntervalSinceReferenceDate - selected.updatedAt.timeIntervalSinceReferenceDate) > 2*60 {
                selected.fetch(){data in
                    if((data) != nil){
                        news = data!
                    }
                }
            } else {
                news = selected.body
            }
        }
        
    } .toolbar {
        Button("About") {
            print("About tapped!")
        }
        
        Button("Help") {
            print("Help tapped!")
        }
    }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
