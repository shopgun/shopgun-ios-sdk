import PlaygroundSupport
import Foundation
import ShopGunSDK // NOTE: you must build this targetting an iOS simulator

PlaygroundPage.current.needsIndefiniteExecution = true

// MARK: -

func readCredentialsFile() -> (key: String, secret: String) {

    guard let fileURL = Bundle.main.url(forResource: "credentials.secret", withExtension: "json"),
        let jsonData = (try? String(contentsOf: fileURL, encoding: .utf8))?.data(using: .utf8),
        let credentialsDict = try? JSONDecoder().decode([String: String].self, from: jsonData),
        let key = credentialsDict["key"],
        let secret = credentialsDict["secret"]
        else {
        fatalError("""
Need valid `credentials.secret.json` file in Playground's `Resources` folder. eg: 
{
    "key": "your_key",
    "secret": "your_secret"
}

""")
    }
    return (key: key, secret: secret)
}

let logHandler: ShopGunSDK.LogHandler = { (msg, lvl, source, location) in
    
    
    let output: String
    switch lvl {
    case .error:
        let filename = location.file.components(separatedBy: "/").last ?? location.file
        output = """
        ⁉️ \(msg)
           👉 \(location.function) @ \(filename):\(location.line)
        """
    case .important:
        output = "⚠️ \(msg)"
    case .verbose:
        output = "💬 \(msg)"
    case .debug:
        output = "🕸 \(msg)"
    }
    
    print(output)
}

///////////////////
// Dummy requests

extension CoreAPI.Requests {
    static func allDealers() -> CoreAPI.Request<[CoreAPI.Dealer]> {
        return .init(path: "/v2/dealers", method: .GET, timeoutInterval: 30)
    }
}

///////////////////

let creds = readCredentialsFile()

// must first configure
let coreAPISettings = CoreAPI.Settings(key: creds.key,
                                       secret: creds.secret,
                                       baseURL: URL(string: "https://api-edge.etilbudsavis.dk")!,
                                       locale: Locale.current.identifier,
                                       appVersion: "LH TEST - IGNORE")

ShopGunSDK.configure(settings: .init(coreAPI: coreAPISettings, eventsTracker: nil), logHandler: logHandler)

for i in 0..<5 {
    let token = ShopGunSDK.coreAPI.request(CoreAPI.Requests.allDealers()) { (result) in
        switch result {
        case .error(let error):
            ShopGunSDK.log("Failed: \(error)", level: .error, source: .other(name: "Example"))
        case .success(let dealers):
            ShopGunSDK.log("Success!: \n \(dealers.map({ $0.name }).joined(separator:", "))", level: .important, source: .other(name: "Example"))
        }
    }
    ShopGunSDK.coreAPI.login(credentials: .shopgun(email: "lh+dev@shopgun.com", password: "123456"))
}

//DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
//    ShopGunSDK.coreAPI.cancelAll()
//
//    ShopGunSDK.coreAPI.request(CoreAPI.Requests.allDealers()) { (result) in
//        switch result {
//        case .error(let error):
//            ShopGunSDK.log("xFailed: \(error)", level: .error, source: .other(name: "Example"))
//        case .success(let dealers):
//            ShopGunSDK.log("xSuccess!: \n \(dealers.map({ $0.name }).joined(separator:", "))", level: .important, source: .other(name: "Example"))
//        }
//    }
//}

