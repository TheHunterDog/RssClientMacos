import SwiftUI
import WebKit


struct HTMLView: NSViewRepresentable {
    let htmlString: String
    func makeNSView(context: Context) -> WKWebView {
        let webViewConfiguration = WKWebViewConfiguration()
         let webView = WKWebView(frame: NSRect.zero, configuration: webViewConfiguration)
         webView.autoresizingMask = [.width, .height]

         return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
//        nsView.frame = nsView.superview?.bounds ?? NSRect.zero
        nsView.loadHTMLString(htmlString, baseURL: nil)
//        nsView.frame = nsView.sizeThatFits(NSSize(width: CGFloat.infinity, height: CGFloat.infinity))
//        nsView.frame.width. = nsView.fittingSize.width;
//        nsView.frame.height = nsView.fittingSize.height
        let contentSize = nsView.fittingSize
        nsView.frame.size = CGSize(width: contentSize.width, height: contentSize.height)
        nsView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (result, error) in
            if let height = result as? CGFloat {
                nsView.frame.size.height += height
            }
        })


    }

}


struct HTMLView_Previews: PreviewProvider {
    static var previews: some View {
        HTMLView(htmlString: "<h1>Hello, World!</h1>")
    }
}
