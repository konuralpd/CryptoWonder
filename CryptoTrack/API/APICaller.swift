//
//  Caller.swift
//  CryptoTrack
//
//  Created by Jaf Crisologo on 2022-05-07.
//

import Foundation

final class APICaller {
    static let shared = APICaller()
    
    private struct Constants {
        static let apiKey = "EF5D58B6-A28C-44E9-B006-A8A2A0748857"
        static let assetsEndpoint = "https://rest.coinapi.io/v1/assets/"
    }
    
    private init() {}
    
    public var icons: [Icon] = []
    
    private var whenReadyBlock: ((Result<[Crypto], Error>) -> Void)?
    
    // MARK: - Public
    
    public func getAllCryptoData(
        completion: @escaping (Result<[Crypto], Error>) -> Void
    ) {
        // Only fun this functions when icons are retrieved
        guard !icons.isEmpty else {
            whenReadyBlock = completion
            return
        }
    
        guard let url = URL(string: Constants.assetsEndpoint + "?apikey=" + Constants.apiKey) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                // Decode response
                let cryptos = try JSONDecoder().decode([Crypto].self, from: data)
//                completion(.success(cryptos.sorted { first, second -> Bool in
//                    return first.price_usd ?? 0 > second.price_usd ?? 0
//                }))
                completion(.success(cryptos))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    public func getAllIcons() {
        guard let url = URL(string: "https://rest.coinapi.io/v1/assets/icons/55/?apikey=" + Constants.apiKey) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                // Decode icons
                self?.icons = try JSONDecoder().decode([Icon].self, from: data)
                if let completion = self?.whenReadyBlock {
                    self?.getAllCryptoData(completion: completion)
                }
            } catch {
                print(error)
            }
        }
        
        task.resume()
    }
}
