//
//  PokemonListResponse.swift
//  Pokedex
//
//  Created by Jamong on 1/5/25.
//

import Foundation


/// PokeAPI의 포켓몬 목록 응답을 위한 구조체(모델)
struct PokemonListResponse: Codable {
    /// 전체 결과 수
    let count: Int
    /// 다음 페이지 URL
    let next: String?
    /// 이전 페이지 URL
    let previous: String?
    /// 포켓몬 목록
    let results: [PokemonListItem]
}

/// 포켓몬 목록의 각 아이템
struct PokemonListItem: Codable {
    /// 포켓몬 이름
    let name: String
    /// 포켓몬 상세 정보 URL
    let url: String
    
    /// URL에서 포켓몬 ID 추출
    var id: Int? {
        /// URL :  https://pokeapi.co/api/v2/pokemon/id (id 추출)
        guard let idString = url.split(separator: "/").dropLast().last else {
            return nil
        }
        return Int(idString)
    }
    
    /// 포켓몬 이미지 URL
    var imageUrl: String? {
        guard let id = id else { return nil }
        return "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png"
    }
}
