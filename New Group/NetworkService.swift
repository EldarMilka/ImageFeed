//
//  NetworkService.swift
//  ImageFeed
//
//  Created by Эльдар Милкаманавичюс on 19.10.2025.
//

import Foundation

public final class NetworkService: NetworkServiceProtocol {
    public init() {}
    public func fetchData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error {
                completion(.failure(error))
            } else if let data {
                completion(.success(data))
            }
            
        }.resume()
    }
}
