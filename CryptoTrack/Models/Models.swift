//
//  Models.swift
//  CryptoTrack
//
//  Created by Jaf Crisologo on 2022-05-07.
//

import Foundation

struct Crypto: Codable {
    let asset_id: String
    let name: String?
    let price_usd: Float?
    let id_icon: String?
}

struct Icon: Codable {
    let asset_id: String
    let url: String 
}
