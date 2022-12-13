//
//  GraphQLManager.swift
//  iOSGraphQLExample
//
//  Created by Kotaro Fukuo on 2022/12/02.
//

import Foundation

enum GraphQLResponseError: Error, Equatable {
    case graphQLError(String)
    case decodingError
    case unexpectedError
}

struct GraphQLResponseErrors: Decodable {
    let errors: [GraphQLError]
}

struct GraphQLError: Decodable {
    let message: String
}

struct GraphQLResponse<T: Decodable>: Decodable {
    let data: T
}

protocol Query {
    associatedtype Response: Decodable
    
    var body: String { get }
    static func decodeResponse<T: Decodable>(data: Data, responseFormat: T.Type) throws -> T
    static func decodeQueryErrors(data: Data) -> GraphQLResponseError
}

extension Query {
    static func decodeResponse<T: Decodable>(data: Data, responseFormat: T.Type) throws -> T {
        do {
            return try JSONDecoder().decode(responseFormat, from: data)
        } catch {
            throw GraphQLResponseError.decodingError
        }
    }
    
    static func decodeQueryErrors(data: Data) -> GraphQLResponseError {
        do {
            let error = try JSONDecoder().decode(GraphQLResponseErrors.self, from: data)
            if let msg = error.errors.first?.message, msg != "" {
                return GraphQLResponseError.graphQLError(msg)
            } else {
                return GraphQLResponseError.unexpectedError
            }
        } catch {
            return GraphQLResponseError.unexpectedError
        }
    }
}

struct GraphQLManager {
    let token = "YOUR_API_KEY"
    let session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    func request<T: Query>(
        query: T,
        params: [String: String],
        completion: @escaping (Result<T.Response, GraphQLResponseError>) -> ()
    ) {
        var queryBody = query.body
        for (token, value) in params {
            queryBody = queryBody.replacingOccurrences(of: token, with: value)
        }
        var request = URLRequest(url: URL(string: "https://api.github.com/graphql")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try! JSONSerialization.data(withJSONObject: ["query": queryBody])
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        session.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async {
                if let data = data {
                    do {
                        let decodeResponse = try T.decodeResponse(data: data, responseFormat: GraphQLResponse<T.Response>.self)
                        return completion(.success(decodeResponse.data))
                    } catch {
                        return completion(.failure(T.decodeQueryErrors(data: data)))
                    }
                }
                return completion(.failure(.unexpectedError))
            }
        }.resume()
    }
}
