//
//  PokemonDetailResponse.swift
//  Pokedex
//
//  Created by Jamong on 1/5/25.
//

import Foundation


/// PokeAPI의 포켓몬 상세 정보 응답을 위한 구조체(모델)
struct PokemonDetailResponse: Codable {
    /// 포켓몬 ID
    let id: Int
    /// 포켓몬 이름
    let name: String
    /// 포켓몬 키 (단위: m)
    let height: Int
    /// 포켓몬 몸무게 (단위: Kg)
    let weight: Int
    /// 포켓몬 타입 정보
    let types: [TypeElement]
    
    /// 포켓몬 타입 정보 디코딩 (API 정보 디코딩 필요)
    struct TypeElement: Codable {
        let slot: Int
        let type: TypeName
        
        struct TypeName: Codable {
            let name: String
        }
    }
    
    var heightInMeters: Double {
        return Double(height) / 10.0
    }
    
    var weightInKg: Double {
        return Double(weight) / 10.0
    }
    /// 포켓몬 메인 타입 반환
    var mainType: String {
        return types.first(where: { $0.slot == 1 })?.type.name ?? ""
    }
    /// 포켓몬 이미지 정보
    var imageUrl: String {
        return "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png"
    }
}

