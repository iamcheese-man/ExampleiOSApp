import AppIntents

struct BetterGetURLIntent: AppIntent {
    static var title: LocalizedStringResource = "Better Get Contents of URL"
    static var description = IntentDescription("Advanced URL fetching with headers, methods, and better parsing")
    
    @Parameter(title: "URL")
    var url: String
    
    @Parameter(title: "Method", default: "GET")
    var method: String
    
    @Parameter(title: "Headers (JSON)")
    var headers: String?
    
    @Parameter(title: "Body")
    var body: String?
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        guard let requestURL = URL(string: url) else {
            throw NSError(domain: "Invalid URL", code: 400)
        }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = method
        
        // Parse headers
        if let headers = headers,
           let headerData = headers.data(using: .utf8),
           let headerDict = try? JSONSerialization.jsonObject(with: headerData) as? [String: String] {
            for (key, value) in headerDict {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Add body
        if let body = body {
            request.httpBody = body.data(using: .utf8)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "Invalid response", code: 500)
        }
        
        let responseString = String(data: data, encoding: .utf8) ?? ""
        
        // Pretty print JSON if possible
        if let json = try? JSONSerialization.jsonObject(with: data),
           let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            return .result(value: prettyString)
        }
        
        return .result(value: responseString)
    }
}
