import SwiftUI
import WebKit


struct HTMLView: View {
    let html: String
    
    var body: some View {
        let attributedString = html.attributedString ?? NSAttributedString()
        
        #if os(macOS)
        return Text(attributedString.string).scrollDisabled(true)
        #else
        return Text(attributedString.string)
        #endif
    }
}

extension String {
    var attributedString: NSAttributedString? {
        let data = Data(utf8)
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        return try? NSAttributedString(data: data, options: options, documentAttributes: nil)
    }
}


struct HTMLView_Previews: PreviewProvider {
    static var previews: some View {
        HTMLView(html: "<h1>Hello, World!</h1>")
    }
}
