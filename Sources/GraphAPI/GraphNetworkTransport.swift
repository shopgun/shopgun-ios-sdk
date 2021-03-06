//
//  ┌────┬─┐         ┌─────┐
//  │  ──┤ └─┬───┬───┤  ┌──┼─┬─┬───┐
//  ├──  │ ╷ │ · │ · │  ╵  │ ╵ │ ╷ │
//  └────┴─┴─┴───┤ ┌─┴─────┴───┴─┴─┘
//               └─┘
//
//  Copyright (c) 2017 ShopGun. All rights reserved.

import Foundation

/// An abstract Networking Transport connection. Given a request it will callback with a Result
public protocol GraphNetworkTransport {
    @discardableResult
    func send(request: GraphRequestProtocol, completion: @escaping (Result<GraphResponse, Error>) -> Void) -> Cancellable
    
    @discardableResult
    func send(dataRequest: GraphRequestProtocol, completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable
}

// MARK: - HTTP Network communication

public class HTTPGraphNetworkTransport: GraphNetworkTransport {
    
    let url: URL
    let session: URLSession
    let additionalHeaders: [String: String]?
    
    public init(url: URL, additionalHeaders: [String: String]? = nil, configuration: URLSessionConfiguration = URLSessionConfiguration.default) {
        self.url = url
        self.additionalHeaders = additionalHeaders
        self.session = URLSession(configuration: configuration)
    }
    
    @discardableResult
    public func send(dataRequest: GraphRequestProtocol, completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable {
        
        let urlReq = self.buildURLRequest(for: dataRequest, additionalHeaders: additionalHeaders)
        
        let task = session.dataTask(with: urlReq) { (responseData, response, error) in
            guard let data = responseData else {
                let error = error ?? GraphError(message: "No Response Data", path: [])
                completion(.failure(error))
                return
            }
            
            completion(.success(data))
        }
        
        task.resume()
        
        return task
    }
    
    @discardableResult
    public func send(request: GraphRequestProtocol, completion: @escaping (Result<GraphResponse, Error>) -> Void) -> Cancellable {
        
        return self.send(dataRequest: request) { (resultData: Result<Data, Error>) in
            switch resultData {
            case .failure(let error):
                completion(.failure(error))
            case .success(let jsonData):
                guard let jsonDict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
                    
                    // TODO: Real 'empty/unparseable data' error
                    completion(.failure(GraphError(message: "Invalid JSON", path: [])))
                    
                    return
                }
                
                var data: [String: Any]?
                var errors: [GraphError]?
                
                if let jsonErrors = jsonDict["errors"] as? [[String: Any]] {
                    let possibleErrors = jsonErrors.compactMap(GraphError.init(json:))
                    if possibleErrors.count > 0 {
                        errors = possibleErrors
                    }
                }
                
                if let jsonData = jsonDict["data"] as? [String: Any] {
                    data = jsonData
                }
                
                let graphResponse = GraphResponse(data: data, errors: errors)
                completion(.success(graphResponse))
            }
        }
    }
    
    /// Build a URLRequest based on a GraphRequest
    /// First uses `addValue` to set "Content-Type" & "Accept" headers to the URLRequest,
    /// then adds `graphRequest`'s additionalHeaders
    /// then finally adds the passed-in additionalHeaders parameter
    public func buildURLRequest(for graphRequest: GraphRequestProtocol, additionalHeaders: [String: String]?) -> URLRequest {
        var urlReq = URLRequest(url: self.url)
        
        var jsonDict: [String: Any] = ["query": graphRequest.query.requestString]
        jsonDict["operationName"] = graphRequest.query.operationName
        
        if let vars = graphRequest.query.variables, vars.count > 0 {
            jsonDict["variables"] = vars
        }
        
        urlReq.httpMethod = "POST"
        urlReq.timeoutInterval = graphRequest.timeoutInterval
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: jsonDict),
            let jsonStr = String(data: jsonData, encoding: String.Encoding.utf8) {
            urlReq.httpBody = jsonStr.data(using: String.Encoding.utf8)
        }
        
        urlReq.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlReq.addValue("application/json", forHTTPHeaderField: "Accept")
        
        if let reqHeaders = graphRequest.additionalHeaders {
            for (key, value) in reqHeaders {
                urlReq.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let headers = additionalHeaders {
            for (key, value) in headers {
                urlReq.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        return urlReq
    }
}
