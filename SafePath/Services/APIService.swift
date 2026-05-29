import Foundation
import Combine

/// Generic wrapper for SafePath API responses: { success, count, data }.
struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let count: Int?
    let data: T
}

/// Async networking layer for the SafePath Express backend.
final class APIService {
    
    static let shared = APIService()
    private let session: URLSession
    private let decoder: JSONDecoder
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        session = URLSession(configuration: config)
        
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - Generic GET
    
    /// Fetch and decode a `T` from a SafePath API endpoint.
    func get<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        guard let url = endpoint.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let data: Data
        let response: URLResponse
        
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.networkFailure(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.badResponse(statusCode: -1)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.badResponse(statusCode: httpResponse.statusCode)
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
    // MARK: - Convenience: unwrap APIResponse wrapper
    
    /// Fetch, unwrap the `data` field from the standard `{ success, data }` wrapper.
    func fetchData<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let wrapper: APIResponse<T> = try await get(endpoint)
        return wrapper.data
    }
}

extension APIService {
 
    /// Send a POST/PUT/DELETE request with an optional JSON body and Bearer token.
    /// Returns the decoded response of type `T`.
    func send<T: Decodable>(
        _ endpoint: APIEndpoint,
        authToken: String? = nil,
        body: [String: Any]? = nil
    ) async throws -> T {
        let request = try buildRequest(for: endpoint, authToken: authToken, body: body)
 
        let data: Data
        let response: URLResponse
 
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.networkFailure(error)
        }
 
        guard let http = response as? HTTPURLResponse else {
            throw APIError.badResponse(statusCode: -1)
        }
        guard (200...299).contains(http.statusCode) else {
            throw APIError.badResponse(statusCode: http.statusCode)
        }
 
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
 
    /// Send a request that returns no meaningful response body (e.g. logout, DELETE).
    func sendVoid(
        _ endpoint: APIEndpoint,
        authToken: String? = nil,
        body: [String: Any]? = nil
    ) async throws {
        let request = try buildRequest(for: endpoint, authToken: authToken, body: body)
 
        let response: URLResponse
 
        do {
            (_, response) = try await session.data(for: request)
        } catch {
            throw APIError.networkFailure(error)
        }
 
        guard let http = response as? HTTPURLResponse else {
            throw APIError.badResponse(statusCode: -1)
        }
        guard (200...299).contains(http.statusCode) else {
            throw APIError.badResponse(statusCode: http.statusCode)
        }
    }
 
    // MARK: - Private Builder
 
    private func buildRequest(
        for endpoint: APIEndpoint,
        authToken: String?,
        body: [String: Any]?
    ) throws -> URLRequest {
        guard let url = endpoint.url else {
            throw APIError.invalidURL
        }
 
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
 
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
 
        return request
    }
}
