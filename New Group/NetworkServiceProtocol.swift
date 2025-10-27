//
//  NetworkServiceProtocol.swift
//  ImageFeed
//
//  Created by Эльдар Милкаманавичюс on 19.10.2025.
//

import Foundation

public protocol NetworkServiceProtocol {
    func fetchData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void)
}
