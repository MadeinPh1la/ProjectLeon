//
//  MockURLSession.swift
//  LeonTests
//
//  Created by Kevin Downey on 2/4/24.
//

import Combine
import Foundation
@testable import Leon  // Replace 'Leon' with your actual module name if different

class MockURLSession: URLSessionProtocol {
    var data: Data?
    var response: URLResponse?
    var error: Error?
    
    func fetchData<T: Decodable>(from url: URL, responseType: T.Type) -> AnyPublisher<T, Error> {
        if let error = self.error {
            return Fail(error: error).eraseToAnyPublisher()
        }
        let decoder = JSONDecoder()
        return Just(data ?? Data())
            .decode(type: responseType, decoder: decoder)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
