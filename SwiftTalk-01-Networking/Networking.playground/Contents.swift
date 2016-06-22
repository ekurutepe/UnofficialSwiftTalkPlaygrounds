//: Example Playground for the first episode of Swift Talk available at https://talk.objc.io/episodes/S01E01-networking

import UIKit
import XCPlayground

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

let url = URL(string: "https://raw.githubusercontent.com/ekurutepe/UnofficialSwiftTalkPlaygrounds/master/API/episodes.json")!

struct Resource<A> {
    let url: URL
    let parse: (Data) -> A?
}

extension Resource {
    init(url: URL, parseJSON: (AnyObject) -> A?) {
        self.url = url
        self.parse = { data in
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            return json.flatMap(parseJSON)
        }
    }
}

typealias JSONDictionary = [String: AnyObject]

struct Episode {
    let id: String
    let title: String
    // ...
}

extension Episode {
    init?(dictionary: JSONDictionary) {
        guard let id = dictionary["id"] as? String,
            title = dictionary["title"] as? String else { return nil }
        self.id = id
        self.title = title
    }
}

extension Episode {
    static let all = Resource<[Episode]>(url: url, parseJSON: { json in
        guard let dictionaries = json as? [JSONDictionary] else { return nil }
        return dictionaries.flatMap(Episode.init)
    })
}

final class Webservice {
    func load<A>(resource: Resource<A>, completion: (A?) -> ()) {
        URLSession.shared().dataTask(with: resource.url) { data, _, _ in
            let result = data.flatMap(resource.parse)
            completion(result)
            }.resume()
    }
}

Webservice().load(resource: Episode.all) { result in
    print(result)
}
